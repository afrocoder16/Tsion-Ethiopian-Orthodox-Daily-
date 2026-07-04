import '../../db/app_database.dart';
import '../../db/daos/bible_dao.dart';
import '../book_flow_repositories.dart';
import '../fake/fake_book_flow_repository.dart';

class DbBookDetailRepository implements BookDetailRepository {
  DbBookDetailRepository(this.db);

  final AppDatabase db;

  @override
  Future<BookDetailState> fetchDetail(String id) async {
    final preset = _bookPreset(id);
    final baseState = BookDetailState(
      id: id,
      title: preset.title,
      author: preset.author,
      description: preset.description,
      toc: preset.toc,
      isDownloaded: true,
      resumeLabel: 'Start reading',
    );

    final progress = await db.readingProgressDao.getReadingProgress(id);
    final resumeLabel = progress?.progressText ?? baseState.resumeLabel;

    return BookDetailState(
      id: id,
      title: baseState.title,
      author: baseState.author,
      description: baseState.description,
      toc: baseState.toc,
      isDownloaded: baseState.isDownloaded,
      resumeLabel: resumeLabel,
    );
  }
}

class DbReaderRepository implements ReaderRepository {
  DbReaderRepository(this.db);

  final AppDatabase db;
  final FakeReaderRepository _fallback = FakeReaderRepository();

  @override
  Future<ReaderState> fetchReader(String id) async {
    final state = await _fallback.fetchReader(id);
    await db.readingProgressDao.upsertReadingProgress(
      bookId: id,
      lastLocation: state.chapterLabel,
      progressText: 'Resuming ${state.chapterLabel}',
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    return state;
  }
}

String _titleFromId(String id) {
  return id
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

_BookPreset _bookPreset(String id) {
  switch (id) {
    case 'book-wudase-mariyam':
      return const _BookPreset(
        title: 'Wudase Mariyam',
        author: 'Daily Prayers',
        description: 'Daily praises and petitions to Saint Mary.',
        toc: [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ],
      );
    case 'book-psalms':
      return const _BookPreset(
        title: 'Psalms',
        author: 'Daily Prayers',
        description: 'Prayer through the Psalms.',
        toc: ['Psalm 1', 'Psalm 23', 'Psalm 50', 'Psalm 91'],
      );
    case 'book-sene-gologota':
      return const _BookPreset(
        title: 'Sene Gologota',
        author: 'Daily Prayers',
        description: 'Meditations and prayers on the Passion.',
        toc: [
          'Opening Prayer',
          'Meditation 1',
          'Meditation 2',
          'Closing Prayer',
        ],
      );
    case 'book-seyfe-selase':
      return const _BookPreset(
        title: 'Seyfe Selase',
        author: 'Daily Prayers',
        description: 'Prayers centered on the Holy Trinity.',
        toc: ['Invocation', 'Prayer 1', 'Prayer 2', 'Prayer 3'],
      );
    case 'book-seyfe-melekot':
      return const _BookPreset(
        title: 'Seyfe Melekot',
        author: 'Daily Prayers',
        description: 'Prayers and contemplations of heavenly mysteries.',
        toc: ['Opening', 'Section 1', 'Section 2', 'Section 3'],
      );
    case 'book-andemta-commentary':
      return const _BookPreset(
        title: 'Andemta Commentary',
        author: 'Orthodox Study',
        description: 'Traditional commentary and explanation.',
        toc: ['Introduction', 'Commentary 1', 'Commentary 2', 'Commentary 3'],
      );
    case 'book-bible':
      return const _BookPreset(
        title: 'Bible',
        author: 'Holy Scripture',
        description: 'Open the Bible library and continue reading.',
        toc: ['Old Testament', 'New Testament'],
      );
  }
  return _BookPreset(
    title: _titleFromId(id),
    author: 'Unknown',
    description: 'Continue where you left off.',
    toc: const ['Introduction', 'Chapter 1', 'Chapter 2', 'Chapter 3'],
  );
}

class _BookPreset {
  const _BookPreset({
    required this.title,
    required this.author,
    required this.description,
    required this.toc,
  });

  final String title;
  final String author;
  final String description;
  final List<String> toc;
}

class DbBibleLibraryRepository extends FakeBibleLibraryRepository {
  DbBibleLibraryRepository(this.db);

  final AppDatabase db;

  @override
  Future<BibleLibraryState> fetchLibrary() async {
    final rows = await db.bibleDao.listBooks();
    final books = rows
        .map(
          (row) => BibleBook(
            id: row.id,
            title: '${row.nameEn} / ${row.nameAm}',
            chapters: row.chapters,
          ),
        )
        .toList(growable: false);
    return BibleLibraryState(books: books);
  }
}

class DbPassageRepository implements PassageRepository {
  DbPassageRepository(this.db);

  final AppDatabase db;

  @override
  Future<PassageState> fetchPassage(
    String bookId,
    int chapter, {
    String lang = 'am',
  }) async {
    final book = await db.bibleDao.findBook(bookId);
    if (book == null) {
      throw StateError('Book not found: $bookId');
    }
    final rows = await db.bibleDao.listChapter(bookId, chapter);
    if (rows.isEmpty) {
      throw StateError('Chapter $chapter not found in $bookId');
    }
    return PassageState(
      bookId: bookId,
      bookTitle: _bookTitleForLang(book, lang),
      chapter: chapter,
      verses: rows
          .map(
            (row) => PassageVerse(
              number: row.verse,
              text: _verseTextForLang(row, lang),
            ),
          )
          .toList(growable: false),
    );
  }
}

class DbBibleSearchRepository implements BibleSearchRepository {
  DbBibleSearchRepository(this.db);

  final AppDatabase db;

  @override
  Future<List<BibleSearchResult>> search(
    String query, {
    String lang = 'am',
    int limit = 50,
  }) async {
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery.isEmpty) {
      return const [];
    }
    final rows = await db.bibleDao.searchVerses(ftsQuery, limit: limit);
    return rows
        .map(
          (row) => BibleSearchResult(
            bookId: row.bookId,
            bookTitle: lang == 'en' ? row.bookNameEn : row.bookNameAm,
            chapter: row.chapter,
            verse: row.verse,
            text: _searchTextForLang(row, lang),
            snippet: _searchSnippetForLang(row, lang),
          ),
        )
        .toList(growable: false);
  }
}

String _bookTitleForLang(BibleBookRow book, String lang) {
  return lang == 'en' ? book.nameEn : book.nameAm;
}

String _verseTextForLang(BibleVerseRow verse, String lang) {
  if (lang == 'en') {
    return verse.textEn.isNotEmpty ? verse.textEn : verse.textAm;
  }
  return verse.textAm.isNotEmpty ? verse.textAm : verse.textEn;
}

String _searchTextForLang(BibleSearchRow row, String lang) {
  if (lang == 'en') {
    return row.textEn.isNotEmpty ? row.textEn : row.textAm;
  }
  return row.textAm.isNotEmpty ? row.textAm : row.textEn;
}

String _searchSnippetForLang(BibleSearchRow row, String lang) {
  if (lang == 'en') {
    return row.snippetEn.isNotEmpty ? row.snippetEn : row.textEn;
  }
  return row.snippetAm.isNotEmpty ? row.snippetAm : row.textAm;
}

String _buildFtsQuery(String query) {
  final matches = RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(query);
  final tokens = matches
      .map((match) => match.group(0) ?? '')
      .where((token) => token.isNotEmpty)
      .take(8)
      .map((token) => '$token*')
      .toList(growable: false);
  return tokens.join(' AND ');
}

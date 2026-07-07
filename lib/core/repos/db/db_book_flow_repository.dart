import '../../content/book_content_store.dart';
import '../../db/app_database.dart';
import '../../db/daos/bible_dao.dart';
import '../book_flow_repositories.dart';
import '../fake/fake_book_flow_repository.dart';

class DbBookDetailRepository implements BookDetailRepository {
  DbBookDetailRepository(this.db, this.store);

  final AppDatabase db;
  final BookContentStore store;

  @override
  Future<BookDetailState> fetchDetail(String id) async {
    final book = await store.findById(id);
    if (book == null) {
      throw StateError('Book content not found: $id');
    }
    final progress = await db.readingProgressDao.getReadingProgress(id);
    return BookDetailState(
      id: id,
      title: book.title,
      author: book.author,
      description: book.description,
      toc: book.chapters
          .map((chapter) => chapter.label)
          .toList(growable: false),
      isDownloaded: true,
      resumeLabel: progress?.progressText ?? 'Start reading',
    );
  }
}

class DbReaderRepository implements ReaderRepository {
  DbReaderRepository(this.db, this.store);

  final AppDatabase db;
  final BookContentStore store;

  @override
  Future<ReaderState> fetchReader(String id) async {
    final book = await store.findById(id);
    if (book == null) {
      throw StateError('Book content not found: $id');
    }
    final firstChapter = book.chapters.isNotEmpty
        ? book.chapters.first.label
        : book.title;
    final content = <String>[];
    for (final chapter in book.chapters) {
      content.add(chapter.label);
      content.addAll(chapter.passages);
    }
    final state = ReaderState(
      bookId: id,
      bookTitle: book.title,
      chapterLabel: firstChapter,
      content: content,
    );
    await db.readingProgressDao.upsertReadingProgress(
      bookId: id,
      lastLocation: state.chapterLabel,
      progressText: 'Resuming ${state.chapterLabel}',
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    return state;
  }
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

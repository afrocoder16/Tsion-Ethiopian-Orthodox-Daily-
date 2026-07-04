import '../book_flow_repositories.dart';

class FakeBookDetailRepository implements BookDetailRepository {
  @override
  Future<BookDetailState> fetchDetail(String id) {
    final preset = _bookPreset(id);
    return Future.value(
      BookDetailState(
        id: id,
        title: preset.title,
        author: preset.author,
        description: preset.description,
        toc: preset.toc,
        isDownloaded: false,
        resumeLabel: 'Start reading',
      ),
    );
  }
}

class FakeReaderRepository implements ReaderRepository {
  @override
  Future<ReaderState> fetchReader(String id) {
    return Future.value(
      ReaderState(
        bookId: id,
        bookTitle: _titleFromId(id),
        chapterLabel: 'Chapter 1',
        content: const [
          'Placeholder passage text for this book. Scroll to read.',
          'This is sample content rendered from the repository layer.',
          'Additional text keeps the scroll area active.',
        ],
      ),
    );
  }
}

class FakeBibleLibraryRepository implements BibleLibraryRepository {
  @override
  Future<BibleLibraryState> fetchLibrary() {
    return Future.value(
      const BibleLibraryState(
        books: [
          BibleBook(id: 'genesis', title: 'Genesis', chapters: 50),
          BibleBook(id: 'exodus', title: 'Exodus', chapters: 40),
          BibleBook(id: 'psalms', title: 'Psalms', chapters: 150),
          BibleBook(id: 'matthew', title: 'Matthew', chapters: 28),
          BibleBook(id: 'john', title: 'John', chapters: 21),
          BibleBook(id: 'romans', title: 'Romans', chapters: 16),
        ],
      ),
    );
  }
}

class FakePassageRepository implements PassageRepository {
  @override
  Future<PassageState> fetchPassage(
    String bookId,
    int chapter, {
    String lang = 'am',
  }) {
    final verses = List<PassageVerse>.generate(
      10,
      (index) => PassageVerse(
        number: index + 1,
        text: 'Verse ${index + 1} text from $bookId $chapter.',
      ),
    );
    return Future.value(
      PassageState(
        bookId: bookId,
        bookTitle: _titleFromId(bookId),
        chapter: chapter,
        verses: verses,
      ),
    );
  }
}

class FakeBibleSearchRepository implements BibleSearchRepository {
  @override
  Future<List<BibleSearchResult>> search(
    String query, {
    String lang = 'am',
    int limit = 50,
  }) {
    return Future.value(const []);
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
    author: 'Author Name',
    description:
        'A reflective book in progress. Continue reading where you left off.',
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

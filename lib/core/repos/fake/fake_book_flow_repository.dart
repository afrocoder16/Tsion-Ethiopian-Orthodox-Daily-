import '../book_flow_repositories.dart';

class FakeBookDetailRepository implements BookDetailRepository {
  @override
  Future<BookDetailState> fetchDetail(String id) {
    return Future.value(
      BookDetailState(
        id: id,
        title: _titleFromId(id),
        author: 'Author Name',
        description:
            'A reflective book in progress. Continue reading where you left off.',
        toc: const [
          'Introduction',
          'Chapter 1',
          'Chapter 2',
          'Chapter 3',
        ],
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
  Future<PassageState> fetchPassage(String bookId, int chapter) {
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

String _titleFromId(String id) {
  return id
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

import 'package:collection/collection.dart';

class BookDetailState {
  const BookDetailState({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.toc,
    required this.isDownloaded,
    required this.resumeLabel,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final List<String> toc;
  final bool isDownloaded;
  final String resumeLabel;
}

class ReaderState {
  const ReaderState({
    required this.bookId,
    required this.bookTitle,
    required this.chapterLabel,
    required this.content,
  });

  final String bookId;
  final String bookTitle;
  final String chapterLabel;
  final List<String> content;
}

class BibleBook {
  const BibleBook({
    required this.id,
    required this.title,
    required this.chapters,
  });

  final String id;
  final String title;
  final int chapters;
}

class BibleLibraryState {
  const BibleLibraryState({required this.books});

  final List<BibleBook> books;

  BibleBook? bookById(String id) =>
      books.firstWhereOrNull((book) => book.id == id);
}

class PassageVerse {
  const PassageVerse({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;
}

class PassageState {
  const PassageState({
    required this.bookId,
    required this.bookTitle,
    required this.chapter,
    required this.verses,
  });

  final String bookId;
  final String bookTitle;
  final int chapter;
  final List<PassageVerse> verses;
}

abstract class BookDetailRepository {
  Future<BookDetailState> fetchDetail(String id);
}

abstract class ReaderRepository {
  Future<ReaderState> fetchReader(String id);
}

abstract class BibleLibraryRepository {
  Future<BibleLibraryState> fetchLibrary();
}

abstract class PassageRepository {
  Future<PassageState> fetchPassage(String bookId, int chapter);
}

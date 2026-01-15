class RoutePaths {
  RoutePaths._();

  static const today = '/today';
  static const bible = '/bible';
  static const prayers = '/prayers';
  static const calendar = '/calendar';
  static const explore = '/explore';

  // Books
  static const bookDetail = '/bible/book/:id';
  static const bookReader = '/bible/book/:id/reader';

  // Bible library flow
  static const bibleLibrary = '/bible/library';
  static const bibleChapters = '/bible/library/:book';
  static const biblePassage = '/bible/library/:book/:chapter';

  // Legacy path template (for consistency)
  static const bibleReader = '/bible/reader/:book/:chapter';

  // Helper to generate a real path (safe, no logic)
  static String bibleReaderPath({
    required String book,
    required int chapter,
  }) =>
      '/bible/reader/$book/$chapter';

  static String bookDetailPath(String id) => '/bible/book/$id';

  static String bookReaderPath(String id) => '/bible/book/$id/reader';

  static String bibleLibraryPath() => '/bible/library';

  static String bibleChaptersPath(String book) => '/bible/library/$book';

  static String biblePassagePath(String book, int chapter) =>
      '/bible/library/$book/$chapter';
}

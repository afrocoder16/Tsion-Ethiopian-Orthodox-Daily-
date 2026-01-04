class RoutePaths {
  RoutePaths._();

  static const today = '/today';
  static const bible = '/bible';
  static const prayers = '/prayers';
  static const calendar = '/calendar';

  // Full path template (for consistency)
  static const bibleReader = '/bible/reader/:book/:chapter';

  // Helper to generate a real path (safe, no logic)
  static String bibleReaderPath({
    required String book,
    required int chapter,
  }) =>
      '/bible/reader/$book/$chapter';
}

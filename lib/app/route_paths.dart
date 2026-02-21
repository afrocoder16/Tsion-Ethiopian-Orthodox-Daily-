class RoutePaths {
  RoutePaths._();

  static const today = '/today';
  static const bible = '/bible';
  static const prayers = '/prayers';
  static const prayersDaily = '/prayers/daily';
  static const prayersMezmur = '/prayers/mezmur';
  static const prayersReflection = '/prayers/reflection';
  static const prayersLightCandle = '/prayers/light-candle';
  static const calendar = '/calendar';
  static const calendarFasting = '/calendar/fasting';
  static const explore = '/explore';
  static const streak = '/streak';
  static const patronSaint = '/patron-saint/:name';

  // Books (preferred)
  static const booksRoot = '/books';
  static const bookDetail = '/books/book/:id';
  static const bookReader = '/books/reader/:id';

  // Bible library flow
  static const bibleLibrary = '/books/bible';
  static const bibleChapters = '/books/bible/:book';
  static const biblePassage = '/books/bible/:book/:chapter';

  // Legacy path template (for consistency)
  static const legacyBibleRoot = '/bible';
  static const bibleReader = '/bible/reader/:book/:chapter';

  // Helper to generate a real path (safe, no logic)
  static String bibleReaderPath({required String book, required int chapter}) =>
      '/books/bible/$book/$chapter';

  static String bookDetailPath(String id) => '/books/book/$id';

  static String bookReaderPath(String id) => '/books/reader/$id';

  static String bibleLibraryPath() => '/books/bible';

  static String bibleChaptersPath(String book) => '/books/bible/$book';

  static String biblePassagePath(String book, int chapter) =>
      '/books/bible/$book/$chapter';

  static String prayerDetailPath(String id) => '/prayers/detail/$id';

  static String dailyPrayerPath() => prayersDaily;

  static String mezmurPath() => prayersMezmur;

  static String reflectionPath() => prayersReflection;

  static String lightCandlePath() => prayersLightCandle;

  static String calendarDayLinkPath(String dateKey, String type) =>
      '/calendar/day/$dateKey/link/$type';

  static String exploreItemPath(String id) => '/explore/item/$id';

  static String explorePathPath(String id) => '/explore/path/$id';

  static String exploreCommunityPath(String id) => '/explore/community/$id';

  static String streakPath() => '/streak';

  static String calendarFastingPath() => calendarFasting;

  static String patronSaintPath(String name) =>
      '/patron-saint/${Uri.encodeComponent(name)}';
}

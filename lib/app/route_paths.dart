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
  static const calendarReadings = '/calendar/readings';
  static const calendarSynaxarium = '/calendar/synaxarium/:date';
  static const calendarSynaxariumBookmarks = '/calendar/synaxarium/bookmarks';
  static const calendarSynaxariumEntry = '/calendar/synaxarium/entry/:ethKey';
  static const explore = '/explore';
  static const streak = '/streak';
  static const streakDailyVerse = '/streak/daily-verse';
  static const streakPrayer = '/streak/prayer/:id';
  static const streakReadings = '/streak/readings';
  static const streakSynaxarium = '/streak/synaxarium/:date';
  static const patronSaint = '/patron-saint/:name';
  static const profile = '/profile';
  static const profileSignIn = '/profile/sign-in';
  static const profileSignUp = '/profile/sign-up';
  static const profileForgotPassword = '/profile/forgot-password';
  static const profileEdit = '/profile/edit';
  static const profilePreferences = '/profile/preferences';
  static const profilePrayerReminders = '/profile/prayer-reminders';
  static const profileNotifications = '/profile/notifications';

  // Books (preferred)
  static const booksRoot = '/books';
  static const bookDetail = '/books/book/:id';
  static const bookReader = '/books/reader/:id';
  static const dailyPrayersBooks = '/books/daily-prayers';

  // Bible library flow
  static const bibleLibrary = '/books/bible';
  static const bibleChapters = '/books/bible/:book';
  static const biblePassage = '/books/bible/:book/:chapter';

  // Legacy path template (for consistency)
  static const legacyBibleRoot = '/bible';
  static const bibleReader = '/bible/reader/:book/:chapter';

  // Helper to generate a real path (safe, no logic)
  static String bibleReaderPath({
    required String book,
    required int chapter,
    bool trackForContinueReading = false,
  }) => biblePassagePath(
    book,
    chapter,
    trackForContinueReading: trackForContinueReading,
  );

  static String bookDetailPath(String id) => '/books/book/$id';

  static String bookReaderPath(String id) => '/books/reader/$id';

  static String dailyPrayersBooksPath() => dailyPrayersBooks;

  static String bibleLibraryPath() => '/books/bible';

  static String bibleChaptersPath(String book) => '/books/bible/$book';

  static String biblePassagePath(
    String book,
    int chapter, {
    bool trackForContinueReading = false,
  }) {
    final base = '/books/bible/$book/$chapter';
    if (!trackForContinueReading) {
      return base;
    }
    return '$base?trackResume=1';
  }

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

  static String streakDailyVersePath() => streakDailyVerse;

  static String streakPrayerPath(String id) => '/streak/prayer/$id';

  static String streakReadingsPath() => streakReadings;

  static String streakSynaxariumPath(String dateKey) =>
      '/streak/synaxarium/$dateKey';

  static String calendarFastingPath() => calendarFasting;

  static String calendarReadingsPath() => calendarReadings;

  static String calendarSynaxariumPath(String dateKey) =>
      '/calendar/synaxarium/$dateKey';

  static String calendarSynaxariumBookmarksPath() =>
      calendarSynaxariumBookmarks;

  static String calendarSynaxariumEntryPath(String ethKey) =>
      '/calendar/synaxarium/entry/$ethKey';

  static String patronSaintPath(String name) =>
      '/patron-saint/${Uri.encodeComponent(name)}';

  static String profilePath() => profile;

  static String profileSignInPath() => profileSignIn;

  static String profileSignUpPath() => profileSignUp;

  static String profileForgotPasswordPath() => profileForgotPassword;

  static String profileEditPath() => profileEdit;

  static String profilePreferencesPath() => profilePreferences;

  static String profilePrayerRemindersPath() => profilePrayerReminders;

  static String profileNotificationsPath() => profileNotifications;
}

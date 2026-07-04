class AppStrings {
  AppStrings._();

  static const prayerReminderTitle = 'Prayer reminder';
  static const prayerReminderChannelName = 'Prayer reminders';
  static const prayerReminderChannelDescription =
      'Daily prayer reminder notifications';
  static const bibleLibraryTitle = 'Bible Library';
  static const biblePreparingLibrary = 'Preparing your library';
  static const bibleSearchHint = 'Search Bible text';
  static const bibleSearchEmpty = 'No matching verses found';
  static const unableToLoadBibleLibrary = 'Unable to load Bible library';
  static const retry = 'Retry';
  static const signInUnlockTitle = 'Sign in to unlock';
  static const signInUnlockSignIn = 'Sign in';
  static const signInUnlockNotNow = 'Not now';
  static const signInUnlockBookmarks =
      'Sign in to save bookmarks and keep them in sync across devices.';
  static const signInUnlockStreak =
      'Sign in to start tracking your daily practice and streak history.';
  static const signInUnlockPersonalPrayerList =
      'Sign in to keep a personal prayer list for yourself and your family.';
  static const signInUnlockMezmur =
      'Sign in to play Mezmur audio and keep your listening library.';
  static const signInUnlockLightCandle =
      'Sign in to offer and remember candle intentions.';
  static const signInUnlockDailyReflection =
      'Sign in to keep daily reflections with your account.';
  static const signInUnlockPrayerCompletion =
      'Sign in to mark prayers complete and count them toward your streak.';
  static const signInUnlockProfile =
      'Sign in to manage your profile, preferences, and sync settings.';
  static const onboardingTitle = 'Set your prayer rhythm';
  static const onboardingSubtitle =
      'Choose a reminder pattern. You can change this later in Profile.';
  static const onboardingFourTime = '4-time default';
  static const onboardingFourTimeDescription =
      'Morning, noon, evening, and night.';
  static const onboardingSevenTime = '7-time rhythm';
  static const onboardingSevenTimeDescription =
      'A fuller daily rhythm with the hours of prayer.';
  static const onboardingCustom = 'Custom';
  static const onboardingCustomDescription =
      'Start with four times and adjust each reminder.';
  static const onboardingOptionalSignIn = 'Optional account setup';
  static const onboardingContinue = 'Continue';
  static const onboardingComplete = 'Start Today';
  static const onboardingUnableToLoad = 'Unable to load onboarding';
  static const onboardingNotificationNote =
      'We will ask notification permission so reminders can fire on time.';

  static String prayerReminderBody(String label) {
    return 'It is time for $label prayer.';
  }

  static String bibleChaptersCount(int count) {
    return count == 1 ? '1 chapter' : '$count chapters';
  }
}

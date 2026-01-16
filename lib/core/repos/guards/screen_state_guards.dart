import '../screen_states.dart';

void assertValidTodayScreen(TodayScreenState state) {
  _require(state.header.title, 'today.header.title');
  _require(state.header.greeting, 'today.header.greeting');
  _require(state.header.dateText, 'today.header.dateText');
  _require(state.header.calendarLabel, 'today.header.calendarLabel');
  for (final action in state.headerActions) {
    _require(action.iconKey, 'today.headerActions.iconKey');
  }
  _requireId(state.verseCard.id, 'today.verseCard.id');
  _require(state.verseCard.title, 'today.verseCard.title');
  _require(state.verseCard.reference, 'today.verseCard.reference');
  _require(state.verseCard.body, 'today.verseCard.body');
  for (final stat in state.verseStats) {
    _require(stat.iconKey, 'today.verseStats.iconKey');
    _require(stat.label, 'today.verseStats.label');
  }
  _requireId(state.audioCard.id, 'today.audioCard.id');
  _require(state.audioCard.title, 'today.audioCard.title');
  _require(state.audioCard.subtitle, 'today.audioCard.subtitle');
  _require(state.audioCard.durationText, 'today.audioCard.durationText');
  _require(state.memoryCue.text, 'today.memoryCue.text');
  _require(state.orthodoxDailyHeader.title, 'today.orthodoxDailyHeader.title');
  for (final item in state.orthodoxDailyItems) {
    _requireId(item.id, 'today.orthodoxDailyItems.id');
    _require(item.title, 'today.orthodoxDailyItems.title');
    _require(item.subtitle, 'today.orthodoxDailyItems.subtitle');
  }
  _require(state.studyWorshipHeader.title, 'today.studyWorshipHeader.title');
  for (final item in state.studyWorshipItems) {
    _requireId(item.id, 'today.studyWorshipItems.id');
    _require(item.title, 'today.studyWorshipItems.title');
    _require(item.subtitle, 'today.studyWorshipItems.subtitle');
  }
}

void assertValidBooksScreen(BooksScreenState state) {
  _require(state.readingStreakBadge.label, 'books.readingStreakBadge.label');
  _require(state.searchBar.placeholder, 'books.searchBar.placeholder');
  for (final filter in state.filters) {
    _require(filter.text, 'books.filters.text');
    _require(filter.value, 'books.filters.value');
  }
  _require(state.filterSelection.selected, 'books.filterSelection.selected');
  _require(state.continueReadingHeader.title, 'books.continueReadingHeader.title');
  for (final item in state.continueReadingItems) {
    _requireId(item.id, 'books.continueReadingItems.id');
    _require(item.title, 'books.continueReadingItems.title');
  }
  _require(state.continueReadingAction.label, 'books.continueReadingAction.label');
  _require(state.saintsHeader.title, 'books.saintsHeader.title');
  _requireId(state.patronSaint.id, 'books.patronSaint.id');
  _require(state.patronSaint.label, 'books.patronSaint.label');
  _require(state.patronSaint.name, 'books.patronSaint.name');
  for (final item in state.saintsShelf) {
    _requireId(item.id, 'books.saintsShelf.id');
    _require(item.title, 'books.saintsShelf.title');
  }
  _require(state.libraryHeader.title, 'books.libraryHeader.title');
  for (final item in state.bibleShelf) {
    _requireId(item.id, 'books.bibleShelf.id');
    _require(item.title, 'books.bibleShelf.title');
  }
  _require(state.orthodoxBooksHeader.title, 'books.orthodoxBooksHeader.title');
  for (final item in state.orthodoxBooks) {
    _requireId(item.id, 'books.orthodoxBooks.id');
    _require(item.title, 'books.orthodoxBooks.title');
  }
}

void assertValidPrayersScreen(PrayersScreenState state) {
  _require(state.topBar.title, 'prayers.topBar.title');
  _require(state.primaryPrayerCard.id, 'prayers.primaryPrayerCard.id');
  _require(state.primaryPrayerCard.label, 'prayers.primaryPrayerCard.label');
  _require(state.primaryPrayerCard.title, 'prayers.primaryPrayerCard.title');
  _require(state.primaryPrayerCard.subtitle, 'prayers.primaryPrayerCard.subtitle');
  _require(state.primaryPrayerCard.actionLabel, 'prayers.primaryPrayerCard.actionLabel');
  _require(state.mezmurHeader.title, 'prayers.mezmurHeader.title');
  for (final item in state.mezmurItems) {
    _requireId(item.id, 'prayers.mezmurItems.id');
    _require(item.title, 'prayers.mezmurItems.title');
    _require(item.subtitle, 'prayers.mezmurItems.subtitle');
    _require(item.iconKey, 'prayers.mezmurItems.iconKey');
  }
  _require(state.devotionalHeader.title, 'prayers.devotionalHeader.title');
  for (final item in state.devotionalItems) {
    _requireId(item.id, 'prayers.devotionalItems.id');
    _require(item.title, 'prayers.devotionalItems.title');
    _require(item.subtitle, 'prayers.devotionalItems.subtitle');
    _require(item.iconKey, 'prayers.devotionalItems.iconKey');
  }
  _require(state.myPrayersHeader.title, 'prayers.myPrayersHeader.title');
  for (final item in state.myPrayers) {
    _require(item.title, 'prayers.myPrayers.title');
  }
  _require(state.recentHeader.title, 'prayers.recentHeader.title');
  _require(state.recentLine.text, 'prayers.recentLine.text');
}

void assertValidCalendarScreen(CalendarScreenState state) {
  _require(state.topBar.title, 'calendar.topBar.title');
  _require(state.topBar.subtitle, 'calendar.topBar.subtitle');
  for (final item in state.months) {
    _require(item.label, 'calendar.months.label');
  }
  _require(state.todayStatus.ethiopianDate, 'calendar.todayStatus.ethiopianDate');
  _require(state.todayStatus.gregorianDate, 'calendar.todayStatus.gregorianDate');
  for (final item in state.signals) {
    _require(item.label, 'calendar.signals.label');
    _require(item.value, 'calendar.signals.value');
  }
  for (final item in state.observances) {
    _require(item.type, 'calendar.observances.type');
    _require(item.label, 'calendar.observances.label');
  }
  for (final item in state.todayActions) {
    _require(item.label, 'calendar.todayActions.label');
    _require(item.iconKey, 'calendar.todayActions.iconKey');
  }
  _require(state.upcomingHeader.title, 'calendar.upcomingHeader.title');
  for (final item in state.upcomingDays) {
    _requireId(item.id, 'calendar.upcomingDays.id');
    _require(item.date, 'calendar.upcomingDays.date');
    _require(item.saint, 'calendar.upcomingDays.saint');
    _require(item.label, 'calendar.upcomingDays.label');
  }
}

void assertValidExploreScreen(ExploreScreenState state) {
  _require(state.topBar.title, 'explore.topBar.title');
  _require(state.topBar.subtitle, 'explore.topBar.subtitle');
  _require(state.studyHeader.title, 'explore.studyHeader.title');
  for (final item in state.studyItems) {
    _requireId(item.id, 'explore.studyItems.id');
    _require(item.title, 'explore.studyItems.title');
    _require(item.subtitle, 'explore.studyItems.subtitle');
  }
  _require(state.guidedHeader.title, 'explore.guidedHeader.title');
  for (final item in state.guidedPaths) {
    _require(item.title, 'explore.guidedPaths.title');
  }
  _require(state.communityHeader.title, 'explore.communityHeader.title');
  for (final item in state.communityItems) {
    _require(item.title, 'explore.communityItems.title');
  }
  _require(state.categoriesHeader.title, 'explore.categoriesHeader.title');
  for (final item in state.categories) {
    _require(item.label, 'explore.categories.label');
  }
  _require(state.contentHeader.title, 'explore.contentHeader.title');
  for (final item in state.contentItems) {
    _requireId(item.id, 'explore.contentItems.id');
    _require(item.title, 'explore.contentItems.title');
    _require(item.category, 'explore.contentItems.category');
  }
  _require(state.savedHeader.title, 'explore.savedHeader.title');
  for (final item in state.savedItems) {
    _requireId(item.id, 'explore.savedItems.id');
    _require(item.title, 'explore.savedItems.title');
  }
}

void _require(String value, String label) {
  if (value.trim().isEmpty) {
    throw StateError('Missing $label');
  }
}

void _requireId(String value, String label) {
  if (value.trim().isEmpty) {
    throw StateError('Missing $label');
  }
}

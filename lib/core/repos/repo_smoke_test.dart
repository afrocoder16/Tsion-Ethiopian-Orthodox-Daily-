import '../models/ui_contract/ui_contract_models.dart';
import 'fake/fake_books_repository.dart';
import 'fake/fake_calendar_repository.dart';
import 'fake/fake_explore_repository.dart';
import 'fake/fake_prayers_repository.dart';
import 'fake/fake_today_repository.dart';

Future<void> runRepoSmokeTest() async {
  final todayState = await FakeTodayRepository().fetchTodayScreen();
  final booksState = await FakeBooksRepository().fetchBooksScreen();
  final prayersState = await FakePrayersRepository().fetchPrayersScreen();
  final calendarState = await FakeCalendarRepository().fetchCalendarScreen();
  final exploreState = await FakeExploreRepository().fetchExploreScreen();

  final errors = <String>[];

  void checkRequired(String label, String value) {
    if (value.trim().isEmpty) {
      errors.add('Missing $label');
    }
  }

  void checkId(String label, String value) {
    if (value.trim().isEmpty) {
      errors.add('Missing $label id');
    }
  }

  void checkSectionHeader(String label, SectionHeader header) {
    checkRequired('$label.title', header.title);
  }

  checkRequired('today.header.title', todayState.header.title);
  checkRequired('today.header.greeting', todayState.header.greeting);
  checkRequired('today.header.dateText', todayState.header.dateText);
  checkRequired('today.header.calendarLabel', todayState.header.calendarLabel);
  for (final action in todayState.headerActions) {
    checkRequired('today.headerActions.iconKey', action.iconKey);
  }
  checkId('today.verseCard', todayState.verseCard.id);
  checkRequired('today.verseCard.title', todayState.verseCard.title);
  checkRequired('today.verseCard.reference', todayState.verseCard.reference);
  checkRequired('today.verseCard.body', todayState.verseCard.body);
  for (final stat in todayState.verseStats) {
    checkRequired('today.verseStats.iconKey', stat.iconKey);
    checkRequired('today.verseStats.label', stat.label);
  }
  checkId('today.audioCard', todayState.audioCard.id);
  checkRequired('today.audioCard.title', todayState.audioCard.title);
  checkRequired('today.audioCard.subtitle', todayState.audioCard.subtitle);
  checkRequired(
    'today.audioCard.durationText',
    todayState.audioCard.durationText,
  );
  checkRequired('today.memoryCue.text', todayState.memoryCue.text);
  checkSectionHeader(
    'today.orthodoxDailyHeader',
    todayState.orthodoxDailyHeader,
  );
  for (final item in todayState.orthodoxDailyItems) {
    checkId('today.orthodoxDailyItems', item.id);
    checkRequired('today.orthodoxDailyItems.title', item.title);
    checkRequired('today.orthodoxDailyItems.subtitle', item.subtitle);
  }
  checkSectionHeader('today.studyWorshipHeader', todayState.studyWorshipHeader);
  for (final item in todayState.studyWorshipItems) {
    checkId('today.studyWorshipItems', item.id);
    checkRequired('today.studyWorshipItems.title', item.title);
    checkRequired('today.studyWorshipItems.subtitle', item.subtitle);
  }

  checkRequired(
    'books.readingStreakBadge.label',
    booksState.readingStreakBadge.label,
  );
  checkRequired(
    'books.searchBar.placeholder',
    booksState.searchBar.placeholder,
  );
  for (final filter in booksState.filters) {
    checkRequired('books.filters.text', filter.text);
    checkRequired('books.filters.value', filter.value);
  }
  checkRequired(
    'books.filterSelection.selected',
    booksState.filterSelection.selected,
  );
  checkSectionHeader(
    'books.continueReadingHeader',
    booksState.continueReadingHeader,
  );
  for (final item in booksState.continueReadingItems) {
    checkId('books.continueReadingItems', item.id);
    checkRequired('books.continueReadingItems.title', item.title);
  }
  checkRequired(
    'books.continueReadingAction.label',
    booksState.continueReadingAction.label,
  );
  checkSectionHeader('books.saintsHeader', booksState.saintsHeader);
  checkId('books.patronSaint', booksState.patronSaint.id);
  checkRequired('books.patronSaint.label', booksState.patronSaint.label);
  checkRequired('books.patronSaint.name', booksState.patronSaint.name);
  checkRequired(
    'books.patronSaintProfile.title',
    booksState.patronSaintProfile.title,
  );
  checkRequired(
    'books.patronSaintProfile.feastDayLabel',
    booksState.patronSaintProfile.feastDayLabel,
  );
  checkRequired(
    'books.patronSaintProfile.summary',
    booksState.patronSaintProfile.summary,
  );
  for (final tag in booksState.patronSaintProfile.tags) {
    checkRequired('books.patronSaintProfile.tags', tag);
  }
  checkRequired(
    'books.patronSaintProfile.changeTitle',
    booksState.patronSaintProfile.changeTitle,
  );
  checkRequired(
    'books.patronSaintProfile.changeSubtitle',
    booksState.patronSaintProfile.changeSubtitle,
  );
  checkRequired(
    'books.patronSaintProfile.reminderTitle',
    booksState.patronSaintProfile.reminderTitle,
  );
  checkRequired(
    'books.patronSaintProfile.lifeTitle',
    booksState.patronSaintProfile.lifeTitle,
  );
  checkRequired(
    'books.patronSaintProfile.lifeReadTime',
    booksState.patronSaintProfile.lifeReadTime,
  );
  checkRequired(
    'books.patronSaintProfile.lifeBody',
    booksState.patronSaintProfile.lifeBody,
  );
  checkRequired(
    'books.patronSaintProfile.hymnTitle',
    booksState.patronSaintProfile.hymnTitle,
  );
  checkRequired(
    'books.patronSaintProfile.hymnReadTime',
    booksState.patronSaintProfile.hymnReadTime,
  );
  checkRequired(
    'books.patronSaintProfile.hymnBody',
    booksState.patronSaintProfile.hymnBody,
  );
  for (final item in booksState.saintsShelf) {
    checkId('books.saintsShelf', item.id);
    checkRequired('books.saintsShelf.title', item.title);
  }
  checkSectionHeader('books.libraryHeader', booksState.libraryHeader);
  for (final item in booksState.bibleShelf) {
    checkId('books.bibleShelf', item.id);
    checkRequired('books.bibleShelf.title', item.title);
  }
  checkSectionHeader(
    'books.orthodoxBooksHeader',
    booksState.orthodoxBooksHeader,
  );
  for (final item in booksState.orthodoxBooks) {
    checkId('books.orthodoxBooks', item.id);
    checkRequired('books.orthodoxBooks.title', item.title);
  }

  checkRequired('prayers.topBar.title', prayersState.topBar.title);
  checkRequired(
    'prayers.streakIcon.isActive',
    prayersState.streakIcon.isActive.toString(),
  );
  checkId('prayers.primaryPrayerCard', prayersState.primaryPrayerCard.id);
  checkRequired(
    'prayers.primaryPrayerCard.label',
    prayersState.primaryPrayerCard.label,
  );
  checkRequired(
    'prayers.primaryPrayerCard.title',
    prayersState.primaryPrayerCard.title,
  );
  checkRequired(
    'prayers.primaryPrayerCard.subtitle',
    prayersState.primaryPrayerCard.subtitle,
  );
  checkRequired(
    'prayers.primaryPrayerCard.actionLabel',
    prayersState.primaryPrayerCard.actionLabel,
  );
  checkSectionHeader('prayers.mezmurHeader', prayersState.mezmurHeader);
  for (final item in prayersState.mezmurItems) {
    checkId('prayers.mezmurItems', item.id);
    checkRequired('prayers.mezmurItems.title', item.title);
    checkRequired('prayers.mezmurItems.subtitle', item.subtitle);
    checkRequired('prayers.mezmurItems.iconKey', item.iconKey);
  }
  checkSectionHeader('prayers.devotionalHeader', prayersState.devotionalHeader);
  for (final item in prayersState.devotionalItems) {
    checkId('prayers.devotionalItems', item.id);
    checkRequired('prayers.devotionalItems.title', item.title);
    checkRequired('prayers.devotionalItems.subtitle', item.subtitle);
    checkRequired('prayers.devotionalItems.iconKey', item.iconKey);
  }
  checkSectionHeader('prayers.myPrayersHeader', prayersState.myPrayersHeader);
  for (final item in prayersState.myPrayers) {
    checkRequired('prayers.myPrayers.title', item.title);
  }
  checkSectionHeader('prayers.recentHeader', prayersState.recentHeader);
  checkRequired('prayers.recentLine.text', prayersState.recentLine.text);
  checkRequired(
    'prayers.reflectionJournal.title',
    prayersState.reflectionJournal.title,
  );
  checkRequired(
    'prayers.reflectionJournal.gratitudeQuestion',
    prayersState.reflectionJournal.gratitudeQuestion,
  );
  checkRequired(
    'prayers.reflectionJournal.honestCheckQuestion',
    prayersState.reflectionJournal.honestCheckQuestion,
  );
  checkRequired(
    'prayers.reflectionJournal.smallStepQuestion',
    prayersState.reflectionJournal.smallStepQuestion,
  );
  checkRequired(
    'prayers.reflectionJournal.closingLine',
    prayersState.reflectionJournal.closingLine,
  );
  checkRequired(
    'prayers.lightCandleContent.title',
    prayersState.lightCandleContent.title,
  );
  checkRequired(
    'prayers.lightCandleContent.cancelLabel',
    prayersState.lightCandleContent.cancelLabel,
  );
  checkRequired(
    'prayers.lightCandleContent.description',
    prayersState.lightCandleContent.description,
  );
  checkRequired(
    'prayers.lightCandleContent.livingTitle',
    prayersState.lightCandleContent.livingTitle,
  );
  checkRequired(
    'prayers.lightCandleContent.livingSubtitle',
    prayersState.lightCandleContent.livingSubtitle,
  );
  checkRequired(
    'prayers.lightCandleContent.departedTitle',
    prayersState.lightCandleContent.departedTitle,
  );
  checkRequired(
    'prayers.lightCandleContent.departedSubtitle',
    prayersState.lightCandleContent.departedSubtitle,
  );
  checkRequired(
    'prayers.lightCandleContent.namesLabel',
    prayersState.lightCandleContent.namesLabel,
  );
  checkRequired(
    'prayers.lightCandleContent.namesHint',
    prayersState.lightCandleContent.namesHint,
  );
  checkRequired(
    'prayers.lightCandleContent.flashLabel',
    prayersState.lightCandleContent.flashLabel,
  );
  checkRequired(
    'prayers.lightCandleContent.submitLabel',
    prayersState.lightCandleContent.submitLabel,
  );

  checkRequired('calendar.topBar.title', calendarState.topBar.title);
  checkRequired('calendar.topBar.subtitle', calendarState.topBar.subtitle);
  for (final item in calendarState.months) {
    checkRequired('calendar.months.label', item.label);
  }
  checkRequired(
    'calendar.monthGrid.ethiopianMonthLabel',
    calendarState.monthGrid.ethiopianMonthLabel,
  );
  checkRequired(
    'calendar.monthGrid.gregorianRangeLabel',
    calendarState.monthGrid.gregorianRangeLabel,
  );
  for (final label in calendarState.monthGrid.weekdayLabels) {
    checkRequired('calendar.monthGrid.weekdayLabels', label);
  }
  for (final week in calendarState.monthGrid.weeks) {
    if (week.days.length != 7) {
      errors.add('calendar.monthGrid.weeks must contain 7 days each');
    }
    for (final day in week.days) {
      checkId(
        'calendar.monthGrid.weeks.days.gregorianDateKey',
        day.gregorianDateKey,
      );
    }
  }
  for (final grid in calendarState.monthGrids) {
    checkRequired(
      'calendar.monthGrids.ethiopianMonthLabel',
      grid.ethiopianMonthLabel,
    );
    checkRequired(
      'calendar.monthGrids.gregorianRangeLabel',
      grid.gregorianRangeLabel,
    );
    for (final week in grid.weeks) {
      if (week.days.length != 7) {
        errors.add('calendar.monthGrids.weeks must contain 7 days each');
      }
      for (final day in week.days) {
        checkId(
          'calendar.monthGrids.weeks.days.gregorianDateKey',
          day.gregorianDateKey,
        );
      }
    }
  }
  checkRequired(
    'calendar.todayStatus.ethiopianDate',
    calendarState.todayStatus.ethiopianDate,
  );
  checkRequired(
    'calendar.todayStatus.gregorianDate',
    calendarState.todayStatus.gregorianDate,
  );
  checkRequired(
    'calendar.todayStatus.weekday',
    calendarState.todayStatus.weekday,
  );
  for (final rule in calendarState.quickRules) {
    checkRequired('calendar.quickRules', rule);
  }
  checkRequired(
    'calendar.dailyReadings.ctaLabel',
    calendarState.dailyReadings.ctaLabel,
  );
  checkRequired(
    'calendar.dailyReadings.fallbackText',
    calendarState.dailyReadings.fallbackText,
  );
  checkRequired('calendar.prayerOfDay.title', calendarState.prayerOfDay.title);
  checkRequired(
    'calendar.prayerOfDay.preview',
    calendarState.prayerOfDay.preview,
  );
  checkRequired(
    'calendar.prayerOfDay.openPrayersLabel',
    calendarState.prayerOfDay.openPrayersLabel,
  );
  checkRequired(
    'calendar.prayerOfDay.openReadingsLabel',
    calendarState.prayerOfDay.openReadingsLabel,
  );
  checkRequired('calendar.saintPreview.name', calendarState.saintPreview.name);
  checkRequired(
    'calendar.saintPreview.summary',
    calendarState.saintPreview.summary,
  );
  checkRequired(
    'calendar.saintPreview.ctaLabel',
    calendarState.saintPreview.ctaLabel,
  );
  for (final task in calendarState.dayPlanner.tasks) {
    checkId('calendar.dayPlanner.tasks', task.id);
    checkRequired('calendar.dayPlanner.tasks.label', task.label);
  }
  for (final habit in calendarState.spiritualTracker.habits) {
    checkId('calendar.spiritualTracker.habits', habit.id);
    checkRequired('calendar.spiritualTracker.habits.label', habit.label);
  }
  if (calendarState.fastStatus.isFasting) {
    checkRequired(
      'calendar.fastStatus.fastName',
      calendarState.fastStatus.fastName ?? '',
    );
  }
  for (final item in calendarState.signals) {
    checkRequired('calendar.signals.label', item.label);
    checkRequired('calendar.signals.value', item.value);
  }
  for (final item in calendarState.observances) {
    checkRequired('calendar.observances.type', item.type);
    checkRequired('calendar.observances.label', item.label);
  }
  for (final item in calendarState.todayActions) {
    checkRequired('calendar.todayActions.label', item.label);
    checkRequired('calendar.todayActions.iconKey', item.iconKey);
  }
  checkSectionHeader('calendar.upcomingHeader', calendarState.upcomingHeader);
  for (final item in calendarState.upcomingDays) {
    checkId('calendar.upcomingDays', item.id);
    checkRequired('calendar.upcomingDays.date', item.date);
    checkRequired('calendar.upcomingDays.ethDate', item.ethDate);
    checkRequired('calendar.upcomingDays.saint', item.saint);
    checkRequired('calendar.upcomingDays.label', item.label);
  }

  checkRequired('explore.topBar.title', exploreState.topBar.title);
  checkRequired('explore.topBar.subtitle', exploreState.topBar.subtitle);
  checkSectionHeader('explore.studyHeader', exploreState.studyHeader);
  for (final item in exploreState.studyItems) {
    checkId('explore.studyItems', item.id);
    checkRequired('explore.studyItems.title', item.title);
    checkRequired('explore.studyItems.subtitle', item.subtitle);
  }
  checkSectionHeader('explore.guidedHeader', exploreState.guidedHeader);
  for (final item in exploreState.guidedPaths) {
    checkRequired('explore.guidedPaths.title', item.title);
  }
  checkSectionHeader('explore.communityHeader', exploreState.communityHeader);
  for (final item in exploreState.communityItems) {
    checkRequired('explore.communityItems.title', item.title);
  }
  checkSectionHeader('explore.categoriesHeader', exploreState.categoriesHeader);
  for (final item in exploreState.categories) {
    checkRequired('explore.categories.label', item.label);
  }
  checkSectionHeader('explore.contentHeader', exploreState.contentHeader);
  for (final item in exploreState.contentItems) {
    checkId('explore.contentItems', item.id);
    checkRequired('explore.contentItems.title', item.title);
    checkRequired('explore.contentItems.category', item.category);
  }
  checkSectionHeader('explore.savedHeader', exploreState.savedHeader);
  for (final item in exploreState.savedItems) {
    checkId('explore.savedItems', item.id);
    checkRequired('explore.savedItems.title', item.title);
  }

  if (errors.isNotEmpty) {
    throw StateError('Repo smoke test failed:\n${errors.join('\n')}');
  }
}

import '../models/ui_contract/ui_contract_models.dart';

class TodayScreenState {
  const TodayScreenState({
    required this.header,
    required this.headerActions,
    required this.verseCard,
    required this.verseStats,
    required this.audioCard,
    required this.memoryCue,
    required this.orthodoxDailyHeader,
    required this.orthodoxDailyItems,
    required this.studyWorshipHeader,
    required this.studyWorshipItems,
  });

  final TodayHeader header;
  final List<HeaderAction> headerActions;
  final VerseCard verseCard;
  final List<VerseActionStat> verseStats;
  final AudioCard audioCard;
  final MemoryCue memoryCue;
  final SectionHeader orthodoxDailyHeader;
  final List<TodayCarouselItem> orthodoxDailyItems;
  final SectionHeader studyWorshipHeader;
  final List<TodayCarouselItem> studyWorshipItems;
}

class BooksScreenState {
  const BooksScreenState({
    required this.readingStreakBadge,
    required this.searchBar,
    required this.filters,
    required this.filterSelection,
    required this.continueReadingHeader,
    required this.continueReadingItems,
    required this.continueReadingAction,
    required this.saintsHeader,
    required this.patronSaint,
    required this.patronSaintProfile,
    required this.saintsShelf,
    required this.libraryHeader,
    required this.bibleShelf,
    required this.orthodoxBooksHeader,
    required this.orthodoxBooks,
  });

  final ReadingStreakBadge readingStreakBadge;
  final SearchBar searchBar;
  final List<BooksFilterOption> filters;
  final FilterSelection filterSelection;
  final SectionHeader continueReadingHeader;
  final List<BookItem> continueReadingItems;
  final ContinueReadingAction continueReadingAction;
  final SectionHeader saintsHeader;
  final PatronSaintCard patronSaint;
  final PatronSaintProfile patronSaintProfile;
  final List<BookItem> saintsShelf;
  final SectionHeader libraryHeader;
  final List<BookItem> bibleShelf;
  final SectionHeader orthodoxBooksHeader;
  final List<BookItem> orthodoxBooks;
}

class PrayersScreenState {
  const PrayersScreenState({
    required this.topBar,
    required this.streakIcon,
    required this.primaryPrayerCard,
    required this.mezmurHeader,
    required this.mezmurItems,
    required this.devotionalHeader,
    required this.devotionalItems,
    required this.myPrayersHeader,
    required this.myPrayers,
    required this.recentHeader,
    required this.recentLine,
    required this.reflectionJournal,
    required this.lightCandleContent,
  });

  final PrayersTopBar topBar;
  final StreakIcon streakIcon;
  final PrimaryPrayerCard primaryPrayerCard;
  final SectionHeader mezmurHeader;
  final List<DevotionalItem> mezmurItems;
  final SectionHeader devotionalHeader;
  final List<DevotionalItem> devotionalItems;
  final SectionHeader myPrayersHeader;
  final List<PrayerTile> myPrayers;
  final SectionHeader recentHeader;
  final RecentLine recentLine;
  final ReflectionJournal reflectionJournal;
  final LightCandleContent lightCandleContent;
}

class CalendarScreenState {
  const CalendarScreenState({
    required this.topBar,
    required this.months,
    required this.monthGrid,
    required this.monthGrids,
    required this.todayStatus,
    required this.fastStatus,
    required this.quickRules,
    required this.dailyReadings,
    required this.prayerOfDay,
    required this.saintPreview,
    required this.dayPlanner,
    required this.spiritualTracker,
    required this.signals,
    required this.observances,
    required this.todayActions,
    required this.upcomingHeader,
    required this.upcomingDays,
  });

  final CalendarTopBar topBar;
  final List<MonthSelectorItem> months;
  final CalendarMonthGrid monthGrid;
  final List<CalendarMonthGrid> monthGrids;
  final TodayStatusCard todayStatus;
  final FastStatus fastStatus;
  final List<String> quickRules;
  final DailyReadingsPreview dailyReadings;
  final PrayerOfDayPreview prayerOfDay;
  final SaintPreview saintPreview;
  final PersonalDayPlanner dayPlanner;
  final SpiritualTracker spiritualTracker;
  final List<SignalItem> signals;
  final List<ObservanceItem> observances;
  final List<ActionItem> todayActions;
  final SectionHeader upcomingHeader;
  final List<UpcomingDay> upcomingDays;
}

class ExploreScreenState {
  const ExploreScreenState({
    required this.topBar,
    required this.studyHeader,
    required this.studyItems,
    required this.guidedHeader,
    required this.guidedPaths,
    required this.communityHeader,
    required this.communityItems,
    required this.categoriesHeader,
    required this.categories,
    required this.contentHeader,
    required this.contentItems,
    required this.savedHeader,
    required this.savedItems,
  });

  final ExploreTopBar topBar;
  final SectionHeader studyHeader;
  final List<ExploreCardItem> studyItems;
  final SectionHeader guidedHeader;
  final List<SmallTile> guidedPaths;
  final SectionHeader communityHeader;
  final List<SmallTile> communityItems;
  final SectionHeader categoriesHeader;
  final List<CategoryChip> categories;
  final SectionHeader contentHeader;
  final List<ExploreContentItem> contentItems;
  final SectionHeader savedHeader;
  final List<SavedItem> savedItems;
}

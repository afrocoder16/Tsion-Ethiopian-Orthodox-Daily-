import 'package:flutter/material.dart';

import '../icons/icon_registry.dart';
import '../models/ui_contract/ui_contract_models.dart';
import '../repos/screen_states.dart';

IconData iconDataFor(String iconKey) {
  switch (iconKey) {
    case iconKeyAudio:
      return Icons.headphones;
    case iconKeyBookmark:
      return Icons.bookmark;
    case iconKeyShare:
      return Icons.share;
    case iconKeyStreak:
      return Icons.local_fire_department;
    case iconKeyCalendar:
      return Icons.calendar_today;
    case iconKeyPlay:
      return Icons.play_circle_fill;
    case iconKeyCheck:
      return Icons.check_circle;
    case iconKeyInfo:
      return Icons.info;
  }
  return Icons.help_outline;
}

class SectionHeaderView {
  const SectionHeaderView({
    required this.title,
    this.subtitle,
    required this.showSeeAll,
    required this.seeAllLabel,
  });

  final String title;
  final String? subtitle;
  final bool showSeeAll;
  final String seeAllLabel;
}

class TodayHeaderView {
  const TodayHeaderView({
    required this.title,
    required this.greeting,
    required this.dateText,
    required this.calendarLabel,
    required this.actions,
  });

  final String title;
  final String greeting;
  final String dateText;
  final String calendarLabel;
  final List<TodayHeaderActionView> actions;
}

class TodayHeaderActionView {
  const TodayHeaderActionView({required this.iconKey, required this.icon});

  final String iconKey;
  final IconData icon;
}

class ActionStatView {
  const ActionStatView({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class VerseCardView {
  const VerseCardView({
    required this.title,
    required this.reference,
    required this.body,
    required this.stats,
  });

  final String title;
  final String reference;
  final String body;
  final List<ActionStatView> stats;
}

class AudioCardView {
  const AudioCardView({
    required this.title,
    required this.subtitle,
    required this.durationText,
  });

  final String title;
  final String subtitle;
  final String durationText;
}

class TodayCarouselView {
  const TodayCarouselView({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class TodayAdapter {
  TodayAdapter(this.state);

  final TodayScreenState state;

  TodayHeaderView get header => TodayHeaderView(
    title: _safeText(state.header.title, 'TODAY'),
    greeting: _safeText(state.header.greeting, 'Bless you'),
    dateText: _safeText(state.header.dateText, '-'),
    calendarLabel: _safeText(state.header.calendarLabel, '-'),
    actions: state.headerActions
        .map(
          (action) => TodayHeaderActionView(
            iconKey: action.iconKey,
            icon: iconDataFor(action.iconKey),
          ),
        )
        .toList(),
  );

  VerseCardView get verseCard => VerseCardView(
    title: _safeText(state.verseCard.title, 'Verse of the Day'),
    reference: _safeText(state.verseCard.reference, '-'),
    body: _safeText(state.verseCard.body, '-'),
    stats: state.verseStats
        .map(
          (stat) => ActionStatView(
            icon: iconDataFor(stat.iconKey),
            label: _safeText(stat.label, '-'),
          ),
        )
        .toList(),
  );

  AudioCardView get audioCard => AudioCardView(
    title: _safeText(state.audioCard.title, 'Audio'),
    subtitle: _safeText(state.audioCard.subtitle, ''),
    durationText: _safeText(state.audioCard.durationText, '-'),
  );

  String get memoryCueText => _safeText(state.memoryCue.text, 'Continue');

  SectionHeaderView get orthodoxDailyHeader =>
      _sectionHeaderView(state.orthodoxDailyHeader, 'ORTHODOX DAILY');

  List<TodayCarouselView> get orthodoxDailyItems => state.orthodoxDailyItems
      .map(
        (item) => TodayCarouselView(
          id: item.id,
          title: _safeText(item.title, '-'),
          subtitle: _safeText(item.subtitle, ''),
        ),
      )
      .toList();

  SectionHeaderView get studyWorshipHeader =>
      _sectionHeaderView(state.studyWorshipHeader, 'STUDY & WORSHIP');

  List<TodayCarouselView> get studyWorshipItems => state.studyWorshipItems
      .map(
        (item) => TodayCarouselView(
          id: item.id,
          title: _safeText(item.title, '-'),
          subtitle: _safeText(item.subtitle, ''),
        ),
      )
      .toList();
}

class BooksFilterChipView {
  const BooksFilterChipView({
    required this.label,
    required this.value,
    required this.isSelected,
  });

  final String label;
  final String value;
  final bool isSelected;
}

class BookItemView {
  const BookItemView({
    required this.id,
    required this.routeId,
    required this.title,
    this.subtitle,
    required this.isBible,
  });

  final String id;
  final String routeId;
  final String title;
  final String? subtitle;
  final bool isBible;
}

class PatronSaintView {
  const PatronSaintView({required this.label, required this.name});

  final String label;
  final String name;
}

class PatronSaintProfileView {
  const PatronSaintProfileView({
    required this.title,
    required this.feastDayLabel,
    required this.summary,
    required this.tags,
    required this.changeTitle,
    required this.changeSubtitle,
    required this.reminderTitle,
    required this.lifeTitle,
    required this.lifeReadTime,
    required this.lifeBody,
    required this.hymnTitle,
    required this.hymnReadTime,
    required this.hymnBody,
  });

  final String title;
  final String feastDayLabel;
  final String summary;
  final List<String> tags;
  final String changeTitle;
  final String changeSubtitle;
  final String reminderTitle;
  final String lifeTitle;
  final String lifeReadTime;
  final String lifeBody;
  final String hymnTitle;
  final String hymnReadTime;
  final String hymnBody;
}

class BooksAdapter {
  BooksAdapter(this.state);

  final BooksScreenState state;

  String get selectedFilterValue =>
      _safeText(state.filterSelection.selected, '');

  bool get isAllSelected => selectedFilterValue == 'all';

  bool get isBibleSelected => selectedFilterValue == 'bible';

  bool get isSaintsSelected => selectedFilterValue == 'saints';

  String get readingStreakLabel =>
      _safeText(state.readingStreakBadge.label, 'Reading streak');

  bool get readingStreakCompact => state.readingStreakBadge.compact ?? true;

  String get searchPlaceholder =>
      _safeText(state.searchBar.placeholder, 'Search');

  List<BooksFilterChipView> get filterChips {
    return state.filters
        .map(
          (filter) => BooksFilterChipView(
            label: _safeText(filter.text, 'All'),
            value: _safeText(filter.value, ''),
            isSelected: filter.value == selectedFilterValue,
          ),
        )
        .toList();
  }

  SectionHeaderView get continueReadingHeader =>
      _sectionHeaderView(state.continueReadingHeader, 'Continue Reading');

  List<BookItemView> get continueReadingItems => state.continueReadingItems
      .map(
        (item) => BookItemView(
          id: item.id,
          routeId: _safeId(item.id, item.title),
          title: _safeText(item.title, '-'),
          subtitle: _safeOptional(item.subtitle),
          isBible: _isBibleItem(item.id, item.title),
        ),
      )
      .toList();

  String get continueReadingActionLabel =>
      _safeText(state.continueReadingAction.label, 'Resume');

  SectionHeaderView get saintsHeader =>
      _sectionHeaderView(state.saintsHeader, 'Saints');

  PatronSaintView get patronSaint => PatronSaintView(
    label: _safeText(state.patronSaint.label, 'Patron Saint'),
    name: _safeText(state.patronSaint.name, '-'),
  );

  PatronSaintProfileView get patronSaintProfile => PatronSaintProfileView(
    title: _safeText(state.patronSaintProfile.title, 'Saint'),
    feastDayLabel: _safeText(
      state.patronSaintProfile.feastDayLabel,
      'Feast Day',
    ),
    summary: _safeText(state.patronSaintProfile.summary, '-'),
    tags: state.patronSaintProfile.tags
        .map((tag) => _safeText(tag, '-'))
        .toList(),
    changeTitle: _safeText(state.patronSaintProfile.changeTitle, 'Change'),
    changeSubtitle: _safeText(
      state.patronSaintProfile.changeSubtitle,
      'Update',
    ),
    reminderTitle: _safeText(
      state.patronSaintProfile.reminderTitle,
      'Reminder',
    ),
    lifeTitle: _safeText(state.patronSaintProfile.lifeTitle, 'LIFE'),
    lifeReadTime: _safeText(state.patronSaintProfile.lifeReadTime, '-'),
    lifeBody: _safeText(state.patronSaintProfile.lifeBody, '-'),
    hymnTitle: _safeText(state.patronSaintProfile.hymnTitle, 'HYMN'),
    hymnReadTime: _safeText(state.patronSaintProfile.hymnReadTime, '-'),
    hymnBody: _safeText(state.patronSaintProfile.hymnBody, '-'),
  );

  List<BookItemView> get saintsShelf => state.saintsShelf
      .map(
        (item) => BookItemView(
          id: item.id,
          routeId: _safeId(item.id, item.title),
          title: _safeText(item.title, '-'),
          subtitle: _safeOptional(item.subtitle),
          isBible: _isBibleItem(item.id, item.title),
        ),
      )
      .toList();

  SectionHeaderView get libraryHeader =>
      _sectionHeaderView(state.libraryHeader, 'LIBRARY');

  List<BookItemView> get bibleShelf => state.bibleShelf
      .map(
        (item) => BookItemView(
          id: item.id,
          routeId: _safeId(item.id, item.title),
          title: _safeText(item.title, '-'),
          subtitle: _safeOptional(item.subtitle),
          isBible: _isBibleItem(item.id, item.title),
        ),
      )
      .toList();

  SectionHeaderView get orthodoxBooksHeader =>
      _sectionHeaderView(state.orthodoxBooksHeader, 'ORTHODOX BOOKS');

  List<BookItemView> get orthodoxBooks => state.orthodoxBooks
      .map(
        (item) => BookItemView(
          id: item.id,
          routeId: _safeId(item.id, item.title),
          title: _safeText(item.title, '-'),
          subtitle: _safeOptional(item.subtitle),
          isBible: _isBibleItem(item.id, item.title),
        ),
      )
      .toList();
}

class DevotionalItemView {
  const DevotionalItemView({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

class PrayerTileView {
  const PrayerTileView({required this.title, required this.routeId});

  final String title;
  final String routeId;
}

class ReflectionJournalView {
  const ReflectionJournalView({
    required this.title,
    required this.gratitudeQuestion,
    required this.honestCheckQuestion,
    required this.smallStepQuestion,
    required this.closingLine,
  });

  final String title;
  final String gratitudeQuestion;
  final String honestCheckQuestion;
  final String smallStepQuestion;
  final String closingLine;
}

class LightCandleView {
  const LightCandleView({
    required this.title,
    required this.cancelLabel,
    required this.description,
    required this.livingTitle,
    required this.livingSubtitle,
    required this.departedTitle,
    required this.departedSubtitle,
    required this.namesLabel,
    required this.namesHint,
    required this.flashLabel,
    required this.submitLabel,
  });

  final String title;
  final String cancelLabel;
  final String description;
  final String livingTitle;
  final String livingSubtitle;
  final String departedTitle;
  final String departedSubtitle;
  final String namesLabel;
  final String namesHint;
  final String flashLabel;
  final String submitLabel;
}

class PrayersAdapter {
  PrayersAdapter(this.state);

  final PrayersScreenState state;

  String get topBarTitle => _safeText(state.topBar.title, 'PRAYERS');

  bool get streakActive => state.streakIcon.isActive;

  List<IconData> get topBarIcons => const [
    Icons.headphones,
    Icons.calendar_today,
    Icons.person,
  ];

  String get primaryLabel => _safeText(state.primaryPrayerCard.label, 'Prayer');

  String get primaryPrayerId => state.primaryPrayerCard.id;

  String get primaryTitle => _safeText(state.primaryPrayerCard.title, '-');

  String get primarySubtitle =>
      _safeText(state.primaryPrayerCard.subtitle, '-');

  String get primaryActionLabel =>
      _safeText(state.primaryPrayerCard.actionLabel, 'Begin');

  SectionHeaderView get mezmurHeader =>
      _sectionHeaderView(state.mezmurHeader, 'MEZMUR');

  List<DevotionalItemView> get mezmurItems => state.mezmurItems
      .map(
        (item) => DevotionalItemView(
          id: item.id,
          title: _safeText(item.title, '-'),
          subtitle: _safeText(item.subtitle, ''),
          icon: iconDataFor(item.iconKey),
        ),
      )
      .toList();

  SectionHeaderView get devotionalHeader =>
      _sectionHeaderView(state.devotionalHeader, 'DEVOTIONAL');

  List<DevotionalItemView> get devotionalItems => state.devotionalItems
      .map(
        (item) => DevotionalItemView(
          id: item.id,
          title: _safeText(item.title, '-'),
          subtitle: _safeText(item.subtitle, ''),
          icon: iconDataFor(item.iconKey),
        ),
      )
      .toList();

  SectionHeaderView get myPrayersHeader =>
      _sectionHeaderView(state.myPrayersHeader, 'MY PRAYERS');

  List<PrayerTileView> get myPrayers => state.myPrayers
      .map(
        (item) => PrayerTileView(
          title: _safeText(item.title, '-'),
          routeId: _safeId('', item.title),
        ),
      )
      .toList();

  SectionHeaderView get recentHeader =>
      _sectionHeaderView(state.recentHeader, 'RECENT');

  String get recentText => _safeText(state.recentLine.text, '-');

  ReflectionJournalView get reflectionJournal => ReflectionJournalView(
    title: _safeText(state.reflectionJournal.title, 'Daily Reflection'),
    gratitudeQuestion: _safeText(
      state.reflectionJournal.gratitudeQuestion,
      '-',
    ),
    honestCheckQuestion: _safeText(
      state.reflectionJournal.honestCheckQuestion,
      '-',
    ),
    smallStepQuestion: _safeText(
      state.reflectionJournal.smallStepQuestion,
      '-',
    ),
    closingLine: _safeText(state.reflectionJournal.closingLine, '-'),
  );

  LightCandleView get lightCandle => LightCandleView(
    title: _safeText(state.lightCandleContent.title, 'LIGHT A CANDLE'),
    cancelLabel: _safeText(state.lightCandleContent.cancelLabel, 'Cancel'),
    description: _safeText(state.lightCandleContent.description, '-'),
    livingTitle: _safeText(state.lightCandleContent.livingTitle, 'Living'),
    livingSubtitle: _safeText(state.lightCandleContent.livingSubtitle, '-'),
    departedTitle: _safeText(
      state.lightCandleContent.departedTitle,
      'Departed',
    ),
    departedSubtitle: _safeText(state.lightCandleContent.departedSubtitle, '-'),
    namesLabel: _safeText(state.lightCandleContent.namesLabel, 'Names'),
    namesHint: _safeText(state.lightCandleContent.namesHint, '-'),
    flashLabel: _safeText(state.lightCandleContent.flashLabel, '-'),
    submitLabel: _safeText(
      state.lightCandleContent.submitLabel,
      'Light Candle',
    ),
  );
}

class MonthChipView {
  const MonthChipView({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;
}

class ObservanceView {
  const ObservanceView({required this.labelText, required this.valueText});

  final String labelText;
  final String valueText;
}

class CalendarActionView {
  const CalendarActionView({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class FastingGuidanceView {
  const FastingGuidanceView({
    required this.title,
    this.subtitle,
    required this.bullets,
    this.notes,
  });

  final String title;
  final String? subtitle;
  final List<String> bullets;
  final String? notes;
}

class CalendarStatusView {
  const CalendarStatusView({
    required this.ethiopianDate,
    this.ethiopianDateAmharic,
    required this.gregorianDate,
    required this.weekday,
  });

  final String ethiopianDate;
  final String? ethiopianDateAmharic;
  final String gregorianDate;
  final String weekday;
}

class SignalChipView {
  const SignalChipView({
    required this.title,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
}

class DailyReadingsView {
  const DailyReadingsView({
    required this.morning,
    required this.liturgy,
    required this.evening,
    required this.isLoaded,
    required this.ctaLabel,
    required this.fallbackText,
    this.downloadLabel,
  });

  final List<String> morning;
  final List<String> liturgy;
  final List<String> evening;
  final bool isLoaded;
  final String ctaLabel;
  final String fallbackText;
  final String? downloadLabel;
}

class SaintPreviewView {
  const SaintPreviewView({
    required this.name,
    required this.summary,
    required this.isAvailable,
    required this.ctaLabel,
  });

  final String name;
  final String summary;
  final bool isAvailable;
  final String ctaLabel;
}

class UpcomingDayView {
  const UpcomingDayView({
    required this.id,
    required this.date,
    required this.ethDate,
    required this.saint,
    required this.label,
    this.subtitle,
    required this.badges,
  });

  final String id;
  final String date;
  final String ethDate;
  final String saint;
  final String label;
  final String? subtitle;
  final List<String> badges;
}

class CalendarAdapter {
  CalendarAdapter(this.state);

  final CalendarScreenState state;

  String get topBarTitle => _safeText(state.topBar.title, 'CALENDAR');

  String get topBarSubtitle => _safeText(state.topBar.subtitle, '-');

  List<IconData> get topBarIcons => const [Icons.calendar_today, Icons.person];

  List<MonthChipView> get months {
    final items = state.months;
    return List<MonthChipView>.generate(
      items.length,
      (index) => MonthChipView(
        label: _safeText(items[index].label, '-'),
        isSelected: index == 0,
      ),
    );
  }

  CalendarStatusView get status => CalendarStatusView(
    ethiopianDate: _safeText(state.todayStatus.ethiopianDate, '-'),
    ethiopianDateAmharic: _safeOptional(state.todayStatus.ethiopianDateAmharic),
    gregorianDate: _safeText(state.todayStatus.gregorianDate, '-'),
    weekday: _safeText(state.todayStatus.weekday, '-'),
  );

  List<SignalChipView> get signalChips => state.signals
      .map(
        (item) => SignalChipView(
          title: _safeText(item.label, '-'),
          value: _safeText(item.value, '-'),
          subtitle: _safeOptional(item.subtitle),
        ),
      )
      .toList();

  bool get fastingToday => state.fastStatus.isFasting;

  String get fastingType {
    final bySeason = _safeOptional(state.fastStatus.fastName);
    if (bySeason != null) {
      return bySeason;
    }
    final top = _safeOptional(state.fastStatus.topFastReason);
    if (top != null) {
      return top;
    }
    return state.fastStatus.isFasting ? 'Wed/Fri' : 'Regular day';
  }

  List<String> get fastReasons =>
      (state.fastStatus.fastReasons ?? const <String>[])
          .map((item) => _safeText(item, '-'))
          .toList();

  String? get seasonProgressText {
    final p = state.fastStatus.seasonProgress;
    if (p == null) {
      return null;
    }
    return 'Day ${p.dayIndex} of ${p.totalDays}';
  }

  String get todayObservanceTitle => 'Today in the Church';

  List<ObservanceView> get observances => state.observances
      .map(
        (item) => ObservanceView(
          labelText: '${_titleCase(item.type)}:',
          valueText: _safeText(item.label, '-'),
        ),
      )
      .toList();

  List<CalendarActionView> get todayActions => state.todayActions
      .map(
        (item) => CalendarActionView(
          label: _safeText(item.label, '-'),
          icon: iconDataFor(item.iconKey),
        ),
      )
      .toList();

  FastingGuidanceView get fastingGuidance {
    final status = state.fastStatus;
    if (status.isFasting) {
      final fastName = _safeOptional(status.fastName) ?? 'Fasting Day';
      return FastingGuidanceView(
        title: 'Today\'s Fast',
        subtitle: fastName,
        bullets: const [
          'Food rule: no meat/dairy/eggs, keep it simple.',
          'Heart rule: humility, guard mouth/eyes.',
          'Action: prayer + mercy/almsgiving.',
        ],
        notes: _safeOptional(status.notes),
      );
    }
    return FastingGuidanceView(
      title: 'Not a fasting day',
      bullets: const ['Eat with gratitude.', 'Avoid excess.'],
      notes: _safeOptional(status.notes),
    );
  }

  SectionHeaderView get upcomingHeader =>
      _sectionHeaderView(state.upcomingHeader, 'Next 7 days');

  List<UpcomingDayView> get upcomingDays => state.upcomingDays
      .map(
        (item) => UpcomingDayView(
          id: _safeId(item.id, '${item.date}-${item.saint}'),
          date: _safeText(item.date, '-'),
          ethDate: _safeText(item.ethDate, '-'),
          saint: _safeText(item.saint, '-'),
          label: _safeText(item.label, '-'),
          subtitle: _safeOptional(item.subtitle),
          badges: (item.badges ?? const <String>[])
              .map((value) => _safeText(value, '-'))
              .toList(),
        ),
      )
      .toList();

  List<String> get quickRules =>
      state.quickRules.map((item) => _safeText(item, '-')).toList();

  DailyReadingsView get dailyReadings => DailyReadingsView(
    morning: state.dailyReadings.morning
        .map((item) => _safeText(item, '-'))
        .toList(),
    liturgy: state.dailyReadings.liturgy
        .map((item) => _safeText(item, '-'))
        .toList(),
    evening: state.dailyReadings.evening
        .map((item) => _safeText(item, '-'))
        .toList(),
    isLoaded: state.dailyReadings.isLoaded,
    ctaLabel: _safeText(state.dailyReadings.ctaLabel, 'Open readings'),
    fallbackText: _safeText(
      state.dailyReadings.fallbackText,
      'Readings not loaded',
    ),
    downloadLabel: _safeOptional(state.dailyReadings.downloadLabel),
  );

  SaintPreviewView get saintPreview => SaintPreviewView(
    name: _safeText(state.saintPreview.name, 'Not available yet'),
    summary: _safeText(state.saintPreview.summary, 'Tap to read'),
    isAvailable: state.saintPreview.isAvailable,
    ctaLabel: _safeText(state.saintPreview.ctaLabel, 'Read Synaxarium'),
  );
}

class ExploreCardView {
  const ExploreCardView({
    required this.title,
    required this.subtitle,
    required this.routeId,
  });

  final String title;
  final String subtitle;
  final String routeId;
}

class SmallTileView {
  const SmallTileView({required this.title, required this.routeId});

  final String title;
  final String routeId;
}

class CategoryChipView {
  const CategoryChipView({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;
}

class ExploreContentView {
  const ExploreContentView({
    required this.title,
    required this.category,
    required this.routeId,
  });

  final String title;
  final String category;
  final String routeId;
}

class SavedItemView {
  const SavedItemView({required this.id, required this.title});

  final String id;
  final String title;
}

class ExploreAdapter {
  ExploreAdapter(this.state);

  final ExploreScreenState state;

  String get topBarTitle => _safeText(state.topBar.title, 'EXPLORE');

  String get topBarSubtitle => _safeText(state.topBar.subtitle, '-');

  List<IconData> get topBarIcons => const [Icons.calendar_today, Icons.person];

  SectionHeaderView get studyHeader =>
      _sectionHeaderView(state.studyHeader, 'Study');

  List<ExploreCardView> get studyItems => state.studyItems
      .map(
        (item) => ExploreCardView(
          title: _safeText(item.title, '-'),
          subtitle: _safeText(item.subtitle, ''),
          routeId: _safeId(item.id, item.title),
        ),
      )
      .toList();

  SectionHeaderView get guidedHeader =>
      _sectionHeaderView(state.guidedHeader, 'Guided Paths');

  List<SmallTileView> get guidedPaths => state.guidedPaths
      .map(
        (item) => SmallTileView(
          title: _safeText(item.title, '-'),
          routeId: _safeId('', item.title),
        ),
      )
      .toList();

  SectionHeaderView get communityHeader =>
      _sectionHeaderView(state.communityHeader, 'Community');

  List<SmallTileView> get communityItems => state.communityItems
      .map(
        (item) => SmallTileView(
          title: _safeText(item.title, '-'),
          routeId: _safeId('', item.title),
        ),
      )
      .toList();

  SectionHeaderView get categoriesHeader =>
      _sectionHeaderView(state.categoriesHeader, 'Explore Categories');

  List<CategoryChipView> get categories {
    return List<CategoryChipView>.generate(
      state.categories.length,
      (index) => CategoryChipView(
        label: _safeText(state.categories[index].label, '-'),
        isSelected: index == 0,
      ),
    );
  }

  SectionHeaderView get contentHeader =>
      _sectionHeaderView(state.contentHeader, 'Explore Content');

  List<ExploreContentView> get contentItems => state.contentItems
      .map(
        (item) => ExploreContentView(
          title: _safeText(item.title, '-'),
          category: _safeText(item.category, '-'),
          routeId: _safeId(item.id, item.title),
        ),
      )
      .toList();

  SectionHeaderView get savedHeader =>
      _sectionHeaderView(state.savedHeader, 'Saved Content');

  List<SavedItemView> get savedItems => state.savedItems
      .map(
        (item) => SavedItemView(
          id: _safeId(item.id, item.title),
          title: _safeText(item.title, '-'),
        ),
      )
      .toList();

  IconData get savedIcon => iconDataFor(iconKeyBookmark);
}

SectionHeaderView _sectionHeaderView(
  SectionHeader header,
  String fallbackTitle,
) {
  return SectionHeaderView(
    title: _safeText(header.title, fallbackTitle),
    subtitle: _safeOptional(header.subtitle),
    showSeeAll: header.showSeeAll ?? false,
    seeAllLabel: 'See all',
  );
}

String _safeText(String? value, String fallback) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? fallback : trimmed;
}

String? _safeOptional(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

String _safeId(String id, String title) {
  final trimmed = id.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  return _slugFromTitle(title);
}

bool _isBibleItem(String id, String title) {
  if (id.trim() == 'book-bible') {
    return true;
  }
  return title.trim().toLowerCase() == 'bible';
}

String _slugFromTitle(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return 'item';
  }
  return trimmed.toLowerCase().replaceAll(' ', '-');
}

String _titleCase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '-';
  }
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

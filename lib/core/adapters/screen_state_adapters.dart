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
  const TodayHeaderActionView({
    required this.iconKey,
    required this.icon,
  });

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
    required this.title,
    required this.subtitle,
  });

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

  List<TodayCarouselView> get orthodoxDailyItems =>
      state.orthodoxDailyItems
          .map(
            (item) => TodayCarouselView(
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

  List<BookItemView> get continueReadingItems =>
      state.continueReadingItems
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

  List<BookItemView> get saintsShelf =>
      state.saintsShelf
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
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class PrayerTileView {
  const PrayerTileView({required this.title, required this.routeId});

  final String title;
  final String routeId;
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

  String get primaryLabel =>
      _safeText(state.primaryPrayerCard.label, 'Prayer');

  String get primaryPrayerId => state.primaryPrayerCard.id;

  String get primaryTitle =>
      _safeText(state.primaryPrayerCard.title, '-');

  String get primarySubtitle =>
      _safeText(state.primaryPrayerCard.subtitle, '-');

  String get primaryActionLabel =>
      _safeText(state.primaryPrayerCard.actionLabel, 'Begin');

  SectionHeaderView get mezmurHeader =>
      _sectionHeaderView(state.mezmurHeader, 'MEZMUR');

  List<DevotionalItemView> get mezmurItems => state.mezmurItems
      .map(
        (item) => DevotionalItemView(
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
}

class MonthChipView {
  const MonthChipView({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;
}

class ObservanceView {
  const ObservanceView({
    required this.labelText,
    required this.valueText,
  });

  final String labelText;
  final String valueText;
}

class CalendarActionView {
  const CalendarActionView({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class UpcomingDayView {
  const UpcomingDayView({
    required this.date,
    required this.saint,
    required this.label,
  });

  final String date;
  final String saint;
  final String label;
}

class CalendarAdapter {
  CalendarAdapter(this.state);

  final CalendarScreenState state;

  String get topBarTitle => _safeText(state.topBar.title, 'CALENDAR');

  String get topBarSubtitle =>
      _safeText(state.topBar.subtitle, '-');

  List<IconData> get topBarIcons => const [
        Icons.calendar_today,
        Icons.person,
      ];

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

  String get ethiopianDate =>
      _safeText(state.todayStatus.ethiopianDate, '-');

  String get gregorianDate =>
      _safeText(state.todayStatus.gregorianDate, '-');

  List<String> get signalChips => state.signals
      .map((item) => _joinLabelValue(item.label, item.value))
      .toList();

  String get todayObservanceTitle => 'Today Observance';

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

  SectionHeaderView get upcomingHeader =>
      _sectionHeaderView(state.upcomingHeader, 'Upcoming Days');

  List<UpcomingDayView> get upcomingDays => state.upcomingDays
      .map(
        (item) => UpcomingDayView(
          date: _safeText(item.date, '-'),
          saint: _safeText(item.saint, '-'),
          label: _safeText(item.label, '-'),
        ),
      )
      .toList();
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
  const SmallTileView({
    required this.title,
    required this.routeId,
  });

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

  String get topBarSubtitle =>
      _safeText(state.topBar.subtitle, '-');

  List<IconData> get topBarIcons => const [
        Icons.calendar_today,
        Icons.person,
      ];

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

String _joinLabelValue(String label, String value) {
  final safeLabel = _safeText(label, '-');
  final safeValue = _safeText(value, '-');
  return '$safeLabel: $safeValue';
}

String _titleCase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '-';
  }
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

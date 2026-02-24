class TodayHeader {
  const TodayHeader({
    required this.title,
    required this.greeting,
    required this.dateText,
    required this.calendarLabel,
  });

  final String title;
  final String greeting;
  final String dateText;
  final String calendarLabel;
}

class HeaderAction {
  const HeaderAction({required this.iconKey});

  final String iconKey;
}

class VerseCard {
  const VerseCard({
    required this.id,
    required this.title,
    required this.reference,
    required this.body,
  });

  final String id;
  final String title;
  final String reference;
  final String body;
}

class VerseActionStat {
  const VerseActionStat({required this.iconKey, required this.label});

  final String iconKey;
  final String label;
}

class AudioCard {
  const AudioCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationText,
  });

  final String id;
  final String title;
  final String subtitle;
  final String durationText;
}

class MemoryCue {
  const MemoryCue({required this.text});

  final String text;
}

class SectionHeader {
  const SectionHeader({required this.title, this.subtitle, this.showSeeAll});

  final String title;
  final String? subtitle;
  final bool? showSeeAll;
}

class TodayCarouselItem {
  const TodayCarouselItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class ReadingStreakBadge {
  const ReadingStreakBadge({required this.label, this.compact});

  final String label;
  final bool? compact;
}

class SearchBar {
  const SearchBar({required this.placeholder});

  final String placeholder;
}

class BooksFilterOption {
  const BooksFilterOption({required this.text, required this.value});

  final String text;
  final String value;
}

class FilterSelection {
  const FilterSelection({required this.selected});

  final String selected;
}

class BookItem {
  const BookItem({required this.id, required this.title, this.subtitle});

  final String id;
  final String title;
  final String? subtitle;
}

class PatronSaintCard {
  const PatronSaintCard({
    required this.id,
    required this.label,
    required this.name,
  });

  final String id;
  final String label;
  final String name;
}

class PatronSaintProfile {
  const PatronSaintProfile({
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

class ContinueReadingAction {
  const ContinueReadingAction({required this.label, this.progressText});

  final String label;
  final String? progressText;
}

class PrayersTopBar {
  const PrayersTopBar({required this.title});

  final String title;
}

class StreakIcon {
  const StreakIcon({required this.isActive});

  final bool isActive;
}

class PrimaryPrayerCard {
  const PrimaryPrayerCard({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String id;
  final String label;
  final String title;
  final String subtitle;
  final String actionLabel;
}

class DevotionalItem {
  const DevotionalItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
}

class PrayerTile {
  const PrayerTile({required this.title});

  final String title;
}

class RecentLine {
  const RecentLine({required this.text});

  final String text;
}

class ReflectionJournal {
  const ReflectionJournal({
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

class LightCandleContent {
  const LightCandleContent({
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

class CalendarTopBar {
  const CalendarTopBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class MonthSelectorItem {
  const MonthSelectorItem({required this.label});

  final String label;
}

class TodayStatusCard {
  const TodayStatusCard({
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

class CalendarMonthCell {
  const CalendarMonthCell({
    required this.gregorianDateKey,
    required this.gregorianDay,
    required this.ethiopianDay,
    required this.isCurrentMonth,
    required this.isToday,
    required this.hasDot,
  });

  final String gregorianDateKey;
  final int gregorianDay;
  final int ethiopianDay;
  final bool isCurrentMonth;
  final bool isToday;
  final bool hasDot;
}

class CalendarMonthWeek {
  const CalendarMonthWeek({required this.days});

  final List<CalendarMonthCell> days;
}

class CalendarMonthGrid {
  const CalendarMonthGrid({
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.ethiopianMonthLabel,
    required this.ethiopianYear,
    required this.gregorianRangeLabel,
    required this.weekdayLabels,
    required this.weeks,
  });

  final int gregorianYear;
  final int gregorianMonth;
  final String ethiopianMonthLabel;
  final int ethiopianYear;
  final String gregorianRangeLabel;
  final List<String> weekdayLabels;
  final List<CalendarMonthWeek> weeks;
}

class SignalItem {
  const SignalItem({required this.label, required this.value, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;
}

class ObservanceItem {
  const ObservanceItem({required this.type, required this.label});

  final String type;
  final String label;
}

class ActionItem {
  const ActionItem({required this.label, required this.iconKey});

  final String label;
  final String iconKey;
}

class FastStatus {
  const FastStatus({
    required this.isFasting,
    this.fastName,
    this.notes,
    this.fastReasons,
    this.topFastReason,
    this.extraReasonCount,
    this.seasonProgress,
    this.weekdayKey,
    this.evangelistKey,
  });

  final bool isFasting;
  final String? fastName;
  final String? notes;
  final List<String>? fastReasons;
  final String? topFastReason;
  final int? extraReasonCount;
  final SeasonProgress? seasonProgress;
  final String? weekdayKey;
  final String? evangelistKey;
}

class SeasonProgress {
  const SeasonProgress({
    required this.dayIndex,
    required this.totalDays,
    required this.daysRemaining,
  });

  final int dayIndex;
  final int totalDays;
  final int daysRemaining;
}

class DailyReadingsPreview {
  const DailyReadingsPreview({
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

class PrayerOfDayPreview {
  const PrayerOfDayPreview({
    required this.title,
    required this.preview,
    required this.openPrayersLabel,
    required this.openReadingsLabel,
  });

  final String title;
  final String preview;
  final String openPrayersLabel;
  final String openReadingsLabel;
}

class SaintPreview {
  const SaintPreview({
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

class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.label,
    required this.isDone,
  });

  final String id;
  final String label;
  final bool isDone;
}

class PersonalDayPlanner {
  const PersonalDayPlanner({required this.tasks, this.notes, this.event});

  final List<PlannerTask> tasks;
  final String? notes;
  final String? event;
}

class TrackerHabit {
  const TrackerHabit({
    required this.id,
    required this.label,
    required this.isDone,
    this.isOptional,
  });

  final String id;
  final String label;
  final bool isDone;
  final bool? isOptional;
}

class SpiritualTracker {
  const SpiritualTracker({required this.habits});

  final List<TrackerHabit> habits;
}

class UpcomingDay {
  const UpcomingDay({
    required this.id,
    required this.date,
    required this.ethDate,
    required this.saint,
    required this.label,
    this.subtitle,
    this.badges,
  });

  final String id;
  final String date;
  final String ethDate;
  final String saint;
  final String label;
  final String? subtitle;
  final List<String>? badges;
}

class DayDetail {
  const DayDetail({
    required this.date,
    required this.gregorianDate,
    required this.bahireTitle,
    required this.bahireDescription,
    required this.links,
  });

  final String date;
  final String gregorianDate;
  final String bahireTitle;
  final String bahireDescription;
  final List<LinkTile> links;
}

class LinkTile {
  const LinkTile({required this.label});

  final String label;
}

class ExploreTopBar {
  const ExploreTopBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class ExploreCardItem {
  const ExploreCardItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class SmallTile {
  const SmallTile({required this.title});

  final String title;
}

class CategoryChip {
  const CategoryChip({required this.label});

  final String label;
}

class ExploreContentItem {
  const ExploreContentItem({
    required this.id,
    required this.title,
    required this.category,
  });

  final String id;
  final String title;
  final String category;
}

class SavedItem {
  const SavedItem({required this.id, required this.title});

  final String id;
  final String title;
}

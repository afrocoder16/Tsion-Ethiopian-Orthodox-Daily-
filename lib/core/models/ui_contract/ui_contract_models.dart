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
  const VerseActionStat({
    required this.iconKey,
    required this.label,
  });

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
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.showSeeAll,
  });

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
  const ReadingStreakBadge({
    required this.label,
    this.compact,
  });

  final String label;
  final bool? compact;
}

class SearchBar {
  const SearchBar({required this.placeholder});

  final String placeholder;
}

class BooksFilterOption {
  const BooksFilterOption({
    required this.text,
    required this.value,
  });

  final String text;
  final String value;
}

class FilterSelection {
  const FilterSelection({required this.selected});

  final String selected;
}

class BookItem {
  const BookItem({
    required this.id,
    required this.title,
    this.subtitle,
  });

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

class ContinueReadingAction {
  const ContinueReadingAction({
    required this.label,
    this.progressText,
  });

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

class CalendarTopBar {
  const CalendarTopBar({
    required this.title,
    required this.subtitle,
  });

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
    required this.gregorianDate,
  });

  final String ethiopianDate;
  final String gregorianDate;
}

class SignalItem {
  const SignalItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class ObservanceItem {
  const ObservanceItem({
    required this.type,
    required this.label,
  });

  final String type;
  final String label;
}

class ActionItem {
  const ActionItem({
    required this.label,
    required this.iconKey,
  });

  final String label;
  final String iconKey;
}

class UpcomingDay {
  const UpcomingDay({
    required this.id,
    required this.date,
    required this.saint,
    required this.label,
  });

  final String id;
  final String date;
  final String saint;
  final String label;
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
  const ExploreTopBar({
    required this.title,
    required this.subtitle,
  });

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
  const SavedItem({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

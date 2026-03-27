import '../../app/route_paths.dart';
import '../icons/icon_registry.dart';

class StreakTaskDefinition {
  const StreakTaskDefinition({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.routePath,
  });

  final String id;
  final String title;
  final String iconKey;
  final String? routePath;
}

const String streakTaskDailyVerse = 'daily-verse';
const String streakTaskPrayer = 'daily-prayer';
const String streakTaskReadings = 'daily-readings';

List<StreakTaskDefinition> buildStreakTasks() {
  return [
    StreakTaskDefinition(
      id: streakTaskDailyVerse,
      title: 'Daily Verse',
      iconKey: iconKeyBookmark,
      routePath: RoutePaths.today,
    ),
    StreakTaskDefinition(
      id: streakTaskPrayer,
      title: 'Prayer',
      iconKey: iconKeyStreak,
      routePath: RoutePaths.prayerDetailPath('prayer-midday'),
    ),
    StreakTaskDefinition(
      id: streakTaskReadings,
      title: 'Readings',
      iconKey: iconKeyCalendar,
      routePath: RoutePaths.calendarReadingsPath(),
    ),
  ];
}

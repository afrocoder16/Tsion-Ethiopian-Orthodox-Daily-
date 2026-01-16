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
const String streakTaskDailySaint = 'daily-saint';
const String streakTaskFeasts = 'daily-feasts';
const String streakTaskGuidance = 'daily-guidance';

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
      iconKey: iconKeyAudio,
      routePath: RoutePaths.today,
    ),
    StreakTaskDefinition(
      id: streakTaskDailySaint,
      title: 'Daily Saint',
      iconKey: iconKeyInfo,
      routePath: RoutePaths.calendar,
    ),
    StreakTaskDefinition(
      id: streakTaskFeasts,
      title: 'Feasts',
      iconKey: iconKeyCalendar,
      routePath: RoutePaths.calendar,
    ),
    StreakTaskDefinition(
      id: streakTaskGuidance,
      title: 'Guidance',
      iconKey: iconKeyPlay,
      routePath: RoutePaths.explorePathPath('daily-tip'),
    ),
  ];
}

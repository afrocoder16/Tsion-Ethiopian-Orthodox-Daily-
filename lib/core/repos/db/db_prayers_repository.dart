import '../../db/app_database.dart';
import '../../db/daos/prayer_completions_dao.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbPrayersRepository implements PrayersRepository {
  DbPrayersRepository(this.db);

  final AppDatabase db;

  @override
  Future<PrayersScreenState> fetchPrayersScreen() async {
    final todayYmd = _formatYmd(DateTime.now());
    final completions =
        await PrayerCompletionsDao(db).listTodaysCompletions(todayYmd);
    final completionCount = completions.length;
    final hasCompletions = completionCount > 0;

    final recentText = hasCompletions
        ? 'Completed prayers today: $completionCount'
        : 'Last prayed: Midday Prayer - Today';

    final state = PrayersScreenState(
      topBar: const ui.PrayersTopBar(title: 'PRAYERS'),
      streakIcon: ui.StreakIcon(isActive: hasCompletions),
      primaryPrayerCard: const ui.PrimaryPrayerCard(
        id: 'prayer-midday',
        label: 'Prayer for This Moment',
        title: 'Daily Prayer',
        subtitle: 'The prayer appointed for this hour',
        actionLabel: 'Midday Prayer',
      ),
      mezmurHeader: const ui.SectionHeader(title: 'MEZMUR AND HYMEN'),
      mezmurItems: const [
        ui.DevotionalItem(
          id: 'devotional-mezmur',
          title: 'Mezmur',
          subtitle: 'Ethiopian Orthodox mezmurs, like a sacred playlist',
          iconKey: 'audio',
        ),
        ui.DevotionalItem(
          id: 'devotional-kidase',
          title: 'Kidase',
          subtitle: 'Orthodox Tewahedo daily worship service',
          iconKey: 'play',
        ),
      ],
      devotionalHeader: const ui.SectionHeader(title: 'DEVOTIONAL ACTIONS'),
      devotionalItems: const [
        ui.DevotionalItem(
          id: 'devotional-light-candle',
          title: 'Light a Candle',
          subtitle: 'Pray for me',
          iconKey: 'streak',
        ),
        ui.DevotionalItem(
          id: 'devotional-daily-reflection',
          title: 'Daily Reflection',
          subtitle: 'A quiet question for the heart',
          iconKey: 'info',
        ),
        ui.DevotionalItem(
          id: 'devotional-fasting',
          title: 'Fasting',
          subtitle: 'Today\'s fasting guidance',
          iconKey: 'check',
        ),
      ],
      myPrayersHeader: const ui.SectionHeader(title: 'MY PRAYERS'),
      myPrayers: const [
        ui.PrayerTile(title: 'Trisagion Prayers'),
        ui.PrayerTile(title: 'Psalm 50'),
        ui.PrayerTile(title: 'Prayer of St. Ephrem'),
      ],
      recentHeader: const ui.SectionHeader(title: 'RECENT'),
      recentLine: ui.RecentLine(text: recentText),
    );
    assert(() {
      assertValidPrayersScreen(state);
      return true;
    }());
    return state;
  }
}

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

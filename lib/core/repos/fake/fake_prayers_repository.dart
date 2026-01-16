import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakePrayersRepository implements PrayersRepository {
  @override
  Future<PrayersScreenState> fetchPrayersScreen() {
    final state = PrayersScreenState(
        topBar: const PrayersTopBar(title: 'PRAYERS'),
        streakIcon: const StreakIcon(isActive: true),
        primaryPrayerCard: const PrimaryPrayerCard(
          id: 'prayer-midday',
          label: 'Prayer for This Moment',
          title: 'Midday Prayer',
          subtitle: 'The prayer appointed for this hour',
          actionLabel: 'Begin Prayer',
        ),
        mezmurHeader: const SectionHeader(title: 'MEZMUR AND HYMEN'),
        mezmurItems: const [
          DevotionalItem(
            id: 'devotional-mezmur',
            title: 'Mezmur',
            subtitle: 'Ethiopian Orthodox mezmurs, like a sacred playlist',
            iconKey: 'audio',
          ),
          DevotionalItem(
            id: 'devotional-kidase',
            title: 'Kidase',
            subtitle: 'Orthodox Tewahedo daily worship service',
            iconKey: 'play',
          ),
        ],
        devotionalHeader: const SectionHeader(title: 'DEVOTIONAL ACTIONS'),
        devotionalItems: const [
          DevotionalItem(
            id: 'devotional-light-candle',
            title: 'Light a Candle',
            subtitle: 'Pray for me',
            iconKey: 'streak',
          ),
          DevotionalItem(
            id: 'devotional-daily-reflection',
            title: 'Daily Reflection',
            subtitle: 'A quiet question for the heart',
            iconKey: 'info',
          ),
          DevotionalItem(
            id: 'devotional-fasting',
            title: 'Fasting',
            subtitle: 'Today\'s fasting guidance',
            iconKey: 'check',
          ),
        ],
        myPrayersHeader: const SectionHeader(title: 'MY PRAYERS'),
        myPrayers: const [
          PrayerTile(title: 'Trisagion Prayers'),
          PrayerTile(title: 'Psalm 50'),
          PrayerTile(title: 'Prayer of St. Ephrem'),
        ],
        recentHeader: const SectionHeader(title: 'RECENT'),
        recentLine: const RecentLine(text: 'Last prayed: Midday Prayer - Today'),
      );
    assert(() {
      assertValidPrayersScreen(state);
      return true;
    }());
    return Future.value(state);
  }
}

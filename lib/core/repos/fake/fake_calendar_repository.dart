import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeCalendarRepository implements CalendarRepository {
  @override
  Future<CalendarScreenState> fetchCalendarScreen() {
    final state = CalendarScreenState(
        topBar: const CalendarTopBar(
          title: 'CALENDAR',
          subtitle: 'Orthodox feasts, fasts, and sacred days',
        ),
        months: const [
          MonthSelectorItem(label: 'Today'),
          MonthSelectorItem(label: 'Jan'),
          MonthSelectorItem(label: 'Feb'),
          MonthSelectorItem(label: 'Mar'),
          MonthSelectorItem(label: 'Apr'),
          MonthSelectorItem(label: 'May'),
          MonthSelectorItem(label: 'Jun'),
          MonthSelectorItem(label: 'Jul'),
          MonthSelectorItem(label: 'Aug'),
          MonthSelectorItem(label: 'Sep'),
          MonthSelectorItem(label: 'Oct'),
          MonthSelectorItem(label: 'Nov'),
          MonthSelectorItem(label: 'Dec'),
        ],
        todayStatus: const TodayStatusCard(
          ethiopianDate: 'Tahsas 4',
          gregorianDate: 'December 13',
        ),
        signals: const [
          SignalItem(label: 'Evangelist', value: 'Matthew'),
          SignalItem(label: 'Fast Day', value: 'Wednesday'),
          SignalItem(label: 'Season', value: 'Advent'),
          SignalItem(label: 'Cycle', value: '--'),
          SignalItem(label: 'Day Number', value: '--'),
        ],
        observances: const [
          ObservanceItem(type: 'saint', label: 'St. Lucia'),
          ObservanceItem(type: 'fast', label: 'Wednesday Fast'),
        ],
        todayActions: const [
          ActionItem(label: 'Read Saint', iconKey: 'bookmark'),
          ActionItem(label: 'Fasting Rules', iconKey: 'check'),
          ActionItem(label: 'Open Prayers', iconKey: 'audio'),
        ],
        upcomingHeader: const SectionHeader(title: 'Upcoming Days'),
        upcomingDays: const [
          UpcomingDay(
            id: 'upcoming-dec-14',
            date: 'Dec 14',
            saint: 'St. Ignatius',
            label: 'No fasting',
          ),
          UpcomingDay(
            id: 'upcoming-dec-15',
            date: 'Dec 15',
            saint: 'St. Eleutherius',
            label: 'Feast',
          ),
          UpcomingDay(
            id: 'upcoming-dec-16',
            date: 'Dec 16',
            saint: 'St. Sophia',
            label: 'Friday Fast',
          ),
          UpcomingDay(
            id: 'upcoming-dec-17',
            date: 'Dec 17',
            saint: 'St. Daniel',
            label: 'No fasting',
          ),
        ],
      );
    assert(() {
      assertValidCalendarScreen(state);
      return true;
    }());
    return Future.value(state);
  }
}

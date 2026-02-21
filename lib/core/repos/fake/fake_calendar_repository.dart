import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeCalendarRepository implements CalendarRepository {
  @override
  Future<CalendarScreenState> fetchCalendarScreen() {
    const signals = [
      SignalItem(label: 'Evangelist', value: 'Matthew'),
      SignalItem(label: 'Fasting', value: 'Wed/Fri'),
      SignalItem(
        label: 'Season',
        value: 'Great Lent',
        subtitle: 'Day 12 of 55',
      ),
    ];
    const observances = [
      ObservanceItem(type: 'Fasting today', label: 'Yes'),
      ObservanceItem(type: 'Type', label: 'Great Lent'),
      ObservanceItem(type: 'Reason', label: 'Great Lent'),
      ObservanceItem(type: 'Reason', label: 'Weekly Wed/Fri'),
    ];

    final state = CalendarScreenState(
      topBar: const CalendarTopBar(
        title: 'Orthodox Calendar',
        subtitle: 'Calendar',
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
        ethiopianDate: 'Yekatit 13, 2018 E.C.',
        ethiopianDateAmharic: 'Yekatit 13, 2018',
        gregorianDate: 'Feb 20, 2026',
        weekday: 'Thursday',
      ),
      fastStatus: _deriveFastStatus(signals, observances),
      quickRules: const [
        'Traditional fast: plant-based meals, no animal products.',
        'Guidance varies, follow your father of confession.',
      ],
      dailyReadings: const DailyReadingsPreview(
        morning: [],
        liturgy: [],
        evening: [],
        isLoaded: false,
        ctaLabel: 'Open readings',
        fallbackText: 'Readings not loaded',
        downloadLabel: 'Download monthly readings',
      ),
      saintPreview: const SaintPreview(
        name: 'St Mary',
        summary: 'Tap to read',
        isAvailable: true,
        ctaLabel: 'Read Synaxarium',
      ),
      signals: signals,
      observances: observances,
      todayActions: const [
        ActionItem(label: 'Read Synaxarium', iconKey: 'bookmark'),
        ActionItem(label: 'Fasting Guidance', iconKey: 'check'),
        ActionItem(label: 'Open Prayers', iconKey: 'audio'),
      ],
      upcomingHeader: const SectionHeader(title: 'Next 7 days'),
      upcomingDays: const [
        UpcomingDay(
          id: 'upcoming-dec-14',
          date: 'Feb 21',
          ethDate: 'Yekatit 14',
          saint: 'St Ignatius',
          label: 'Fasting Day',
          subtitle: 'Great Lent',
          badges: ['FAST'],
        ),
        UpcomingDay(
          id: 'upcoming-dec-15',
          date: 'Feb 22',
          ethDate: 'Yekatit 15',
          saint: 'St Eleutherius',
          label: 'Feast: St Eleutherius',
          subtitle: 'Great Lent',
          badges: ['FAST', 'FEAST'],
        ),
        UpcomingDay(
          id: 'upcoming-dec-16',
          date: 'Feb 23',
          ethDate: 'Yekatit 16',
          saint: 'St Sophia',
          label: 'Regular Day',
          subtitle: 'No fasting',
        ),
        UpcomingDay(
          id: 'upcoming-dec-17',
          date: 'Feb 24',
          ethDate: 'Yekatit 17',
          saint: 'St Daniel',
          label: 'Regular Day',
          subtitle: 'No fasting',
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

FastStatus _deriveFastStatus(
  List<SignalItem> signals,
  List<ObservanceItem> observances,
) {
  final fastObservance = observances.firstWhere(
    (item) => item.type.trim().toLowerCase() == 'fast',
    orElse: () => const ObservanceItem(type: '', label: ''),
  );
  final isFasting = fastObservance.label.trim().isNotEmpty;
  if (!isFasting) {
    return const FastStatus(
      isFasting: false,
      notes: 'Follow your confessor and parish guidance.',
    );
  }

  final fastSignal = signals.firstWhere(
    (item) => item.label.trim().toLowerCase() == 'fasting',
    orElse: () => const SignalItem(label: '', value: ''),
  );
  final fastName = fastObservance.label.trim().isNotEmpty
      ? fastObservance.label
      : fastSignal.value;
  return FastStatus(
    isFasting: true,
    fastName: fastName.trim().isEmpty ? null : fastName,
    notes: 'Follow your confessor and parish guidance.',
  );
}

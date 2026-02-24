import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeCalendarRepository implements CalendarRepository {
  @override
  Future<CalendarScreenState> fetchCalendarScreen() {
    const monthGrid = CalendarMonthGrid(
      gregorianYear: 2026,
      gregorianMonth: 2,
      ethiopianMonthLabel: 'የካቲት',
      ethiopianYear: 2018,
      gregorianRangeLabel: 'Feb - Mar 2026',
      weekdayLabels: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
      weeks: [
        CalendarMonthWeek(
          days: [
            CalendarMonthCell(
              gregorianDateKey: '2026-02-01',
              gregorianDay: 1,
              ethiopianDay: 8,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-02',
              gregorianDay: 2,
              ethiopianDay: 9,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-03',
              gregorianDay: 3,
              ethiopianDay: 10,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-04',
              gregorianDay: 4,
              ethiopianDay: 11,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-05',
              gregorianDay: 5,
              ethiopianDay: 12,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-06',
              gregorianDay: 6,
              ethiopianDay: 13,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-07',
              gregorianDay: 7,
              ethiopianDay: 14,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
          ],
        ),
        CalendarMonthWeek(
          days: [
            CalendarMonthCell(
              gregorianDateKey: '2026-02-08',
              gregorianDay: 8,
              ethiopianDay: 15,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-09',
              gregorianDay: 9,
              ethiopianDay: 16,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-10',
              gregorianDay: 10,
              ethiopianDay: 17,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-11',
              gregorianDay: 11,
              ethiopianDay: 18,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-12',
              gregorianDay: 12,
              ethiopianDay: 19,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-13',
              gregorianDay: 13,
              ethiopianDay: 20,
              isCurrentMonth: true,
              isToday: false,
              hasDot: true,
            ),
            CalendarMonthCell(
              gregorianDateKey: '2026-02-14',
              gregorianDay: 14,
              ethiopianDay: 21,
              isCurrentMonth: true,
              isToday: true,
              hasDot: true,
            ),
          ],
        ),
      ],
    );

    const signals = [
      SignalItem(label: 'Evangelist', value: 'Matthew'),
      SignalItem(label: 'Fasting', value: 'Great Lent +1'),
      SignalItem(
        label: 'Season',
        value: 'Great Lent',
        subtitle: 'Day 12 of 55',
      ),
      SignalItem(label: 'Feast', value: 'St Mary'),
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
      months: const [MonthSelectorItem(label: 'Today')],
      monthGrid: monthGrid,
      monthGrids: const [monthGrid],
      todayStatus: const TodayStatusCard(
        ethiopianDate: 'Yekatit 13, 2018 E.C.',
        ethiopianDateAmharic: 'የካቲት 13, 2018',
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
      prayerOfDay: const PrayerOfDayPreview(
        title: 'Prayer of the Day',
        preview: 'Lord Jesus Christ, Son of God, have mercy on me.',
        openPrayersLabel: 'Open Prayers',
        openReadingsLabel: 'Open Readings',
      ),
      saintPreview: const SaintPreview(
        name: 'St Mary',
        summary: 'Tap to read',
        isAvailable: true,
        ctaLabel: 'Read Synaxarium',
      ),
      dayPlanner: const PersonalDayPlanner(
        tasks: [
          PlannerTask(
            id: 'morning-prayer',
            label: 'Morning prayer',
            isDone: false,
          ),
          PlannerTask(
            id: 'daily-reading',
            label: 'Read today\'s passage',
            isDone: false,
          ),
        ],
      ),
      spiritualTracker: const SpiritualTracker(
        habits: [
          TrackerHabit(id: 'prayer', label: 'Prayer done', isDone: false),
          TrackerHabit(id: 'bible', label: 'Bible read', isDone: false),
          TrackerHabit(
            id: 'fasting',
            label: 'Fasting followed',
            isDone: false,
            isOptional: true,
          ),
        ],
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
          id: '2026-02-21',
          date: 'Feb 21',
          ethDate: 'Yekatit 14',
          saint: 'St Ignatius',
          label: 'Fasting Day',
          subtitle: 'Great Lent',
          badges: ['FAST'],
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
    (item) => item.type.trim().toLowerCase() == 'type',
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
  final fastName = fastSignal.value.trim().isEmpty
      ? fastObservance.label
      : fastSignal.value;
  return FastStatus(
    isFasting: true,
    fastName: fastName.trim().isEmpty ? null : fastName,
    notes: 'Follow your confessor and parish guidance.',
  );
}

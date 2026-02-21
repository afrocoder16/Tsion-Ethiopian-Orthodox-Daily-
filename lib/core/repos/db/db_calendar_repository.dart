import '../../calendar/calendar_engine.dart';
import '../../calendar/calendar_engine_models.dart';
import '../../calendar/calendar_observance_store.dart';
import '../../db/app_database.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbCalendarRepository implements CalendarRepository {
  DbCalendarRepository({required this.db, required this.engine});

  final AppDatabase db;
  final CalendarEngine engine;

  @override
  Future<CalendarScreenState> fetchCalendarScreen() async {
    final store = CalendarObservanceStore(db: db, engine: engine);
    final today = DateTime.now();
    final todayObservance = await store.getByGregorianDate(today);
    final todayEth = todayObservance.ethDate;
    final upcoming = await store.getRange(
      today.add(const Duration(days: 1)),
      7,
    );
    final monthGrids = _buildMonthGrids(engine, today);

    final fastReasons = _fastReasonLabels(todayObservance.fastStatus.reasons);
    final topReason = _topReasonLabel(todayObservance.fastStatus, fastReasons);
    final extraReasonCount = fastReasons.length > 1
        ? fastReasons.length - 1
        : 0;
    final seasonProgress = todayObservance.seasonProgress;
    final firstFeast = todayObservance.feasts.isNotEmpty
        ? todayObservance.feasts.first.nameKey
        : null;

    final state = CalendarScreenState(
      topBar: const ui.CalendarTopBar(
        title: 'Orthodox Calendar',
        subtitle: 'Calendar',
      ),
      months: _monthChips(today),
      monthGrid: monthGrids.firstWhere(
        (grid) =>
            grid.gregorianYear == today.year &&
            grid.gregorianMonth == today.month,
        orElse: () => monthGrids.first,
      ),
      monthGrids: monthGrids,
      todayStatus: ui.TodayStatusCard(
        ethiopianDate: _formatEthDate(todayEth),
        ethiopianDateAmharic: _formatEthDateAmharic(todayEth),
        gregorianDate: _formatGregorian(today),
        weekday: todayObservance.weekdayKey,
      ),
      fastStatus: ui.FastStatus(
        isFasting: todayObservance.fastStatus.isFastingDay,
        fastName: todayObservance.fastStatus.seasonNameKey,
        notes: todayObservance.fastStatus.notesKey,
        fastReasons: fastReasons,
        topFastReason: topReason,
        extraReasonCount: extraReasonCount,
        seasonProgress: seasonProgress == null
            ? null
            : ui.SeasonProgress(
                dayIndex: seasonProgress.dayIndex,
                totalDays: seasonProgress.totalDays,
                daysRemaining: seasonProgress.daysRemaining,
              ),
        weekdayKey: todayObservance.weekdayKey,
        evangelistKey: todayObservance.evangelistKey,
      ),
      quickRules: _quickRules(todayObservance.fastStatus.isFastingDay),
      dailyReadings: ui.DailyReadingsPreview(
        morning: todayObservance.dailyReadings.morning,
        liturgy: todayObservance.dailyReadings.liturgy,
        evening: todayObservance.dailyReadings.evening,
        isLoaded: todayObservance.dailyReadings.isLoaded,
        ctaLabel: 'Open readings',
        fallbackText: 'Readings not loaded',
        downloadLabel: todayObservance.dailyReadings.isLoaded
            ? null
            : 'Download monthly readings',
      ),
      prayerOfDay: _prayerOfDay(todayObservance),
      saintPreview: todayObservance.saintsPreview.isEmpty
          ? const ui.SaintPreview(
              name: 'Not available yet',
              summary: 'Tap to read',
              isAvailable: false,
              ctaLabel: 'Read Synaxarium',
            )
          : ui.SaintPreview(
              name: todayObservance.saintsPreview.first.nameKey,
              summary: todayObservance.saintsPreview.first.shortSnippet,
              isAvailable: true,
              ctaLabel: 'Read Synaxarium',
            ),
      dayPlanner: _dayPlanner(todayObservance),
      spiritualTracker: _spiritualTracker(),
      signals: [
        ui.SignalItem(
          label: 'Evangelist',
          value: todayObservance.evangelistKey,
        ),
        ui.SignalItem(
          label: 'Fasting',
          value: topReason == null
              ? 'No'
              : extraReasonCount > 0
              ? '$topReason +$extraReasonCount'
              : topReason,
        ),
        if (todayObservance.fastStatus.seasonNameKey != null)
          ui.SignalItem(
            label: 'Season',
            value: todayObservance.fastStatus.seasonNameKey!,
            subtitle: seasonProgress == null
                ? null
                : 'Day ${seasonProgress.dayIndex} of ${seasonProgress.totalDays}',
          ),
        if (firstFeast != null)
          ui.SignalItem(label: 'Feast', value: firstFeast),
      ],
      observances: _observances(todayObservance),
      todayActions: const [
        ui.ActionItem(label: 'Read Synaxarium', iconKey: 'bookmark'),
        ui.ActionItem(label: 'Fasting Guidance', iconKey: 'check'),
        ui.ActionItem(label: 'Open Prayers', iconKey: 'audio'),
      ],
      upcomingHeader: const ui.SectionHeader(title: 'Next 7 days'),
      upcomingDays: upcoming.map(_mapUpcomingDay).toList(),
    );

    assert(() {
      assertValidCalendarScreen(state);
      return true;
    }());

    return state;
  }
}

List<ui.CalendarMonthGrid> _buildMonthGrids(
  CalendarEngine engine,
  DateTime today,
) {
  final grids = <ui.CalendarMonthGrid>[];
  for (var offset = -120; offset <= 24; offset++) {
    final monthDate = DateTime(today.year, today.month + offset, 1, 12);
    grids.add(_buildMonthGrid(engine, monthDate, today));
  }
  return grids;
}

ui.CalendarMonthGrid _buildMonthGrid(
  CalendarEngine engine,
  DateTime monthDate,
  DateTime today,
) {
  final monthStart = DateTime(monthDate.year, monthDate.month, 1, 12);
  final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0, 12);
  final startOffset = monthStart.weekday % 7;
  final visibleStart = monthStart.subtract(Duration(days: startOffset));
  final endOffset = 6 - (monthEnd.weekday % 7);
  final visibleEnd = monthEnd.add(Duration(days: endOffset));
  final totalDays = visibleEnd.difference(visibleStart).inDays + 1;
  final dayList = <ui.CalendarMonthCell>[];

  for (var i = 0; i < totalDays; i++) {
    final date = visibleStart.add(Duration(days: i));
    final day = engine.getDayObservance(date);
    dayList.add(
      ui.CalendarMonthCell(
        gregorianDateKey: _formatYmd(date),
        gregorianDay: date.day,
        ethiopianDay: day.ethDate.day,
        isCurrentMonth:
            date.month == monthStart.month && date.year == monthStart.year,
        isToday: _sameDate(date, today),
        hasDot: day.fastStatus.isFastingDay || day.feasts.isNotEmpty,
      ),
    );
  }

  var padding = 0;
  while (dayList.length % 7 != 0) {
    padding++;
    final date = visibleEnd.add(Duration(days: padding));
    final day = engine.getDayObservance(date);
    dayList.add(
      ui.CalendarMonthCell(
        gregorianDateKey: _formatYmd(date),
        gregorianDay: date.day,
        ethiopianDay: day.ethDate.day,
        isCurrentMonth:
            date.month == monthStart.month && date.year == monthStart.year,
        isToday: _sameDate(date, today),
        hasDot: day.fastStatus.isFastingDay || day.feasts.isNotEmpty,
      ),
    );
  }

  final weeks = <ui.CalendarMonthWeek>[];
  for (var i = 0; i < dayList.length; i += 7) {
    weeks.add(ui.CalendarMonthWeek(days: dayList.sublist(i, i + 7)));
  }

  final monthEth = engine.ethDateFromGregorian(monthStart);
  final range = monthStart.month == monthEnd.month
      ? '${_monthAbbr(monthStart.month)} ${monthStart.year}'
      : '${_monthAbbr(monthStart.month)} - ${_monthAbbr(monthEnd.month)} ${monthEnd.year}';
  return ui.CalendarMonthGrid(
    gregorianYear: monthStart.year,
    gregorianMonth: monthStart.month,
    ethiopianMonthLabel: _ethMonthAmharic(monthEth.month),
    gregorianRangeLabel: range,
    weekdayLabels: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    weeks: weeks,
  );
}

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatYmd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

ui.PrayerOfDayPreview _prayerOfDay(DayObservance day) {
  final text = day.fastStatus.isFastingDay
      ? 'Lord, grant me repentance, humility, and mercy today.'
      : 'Lord Jesus Christ, Son of God, have mercy on me.';
  return ui.PrayerOfDayPreview(
    title: 'Prayer of the Day',
    preview: text,
    openPrayersLabel: 'Open Prayers',
    openReadingsLabel: 'Open Readings',
  );
}

ui.PersonalDayPlanner _dayPlanner(DayObservance day) {
  final tasks = <ui.PlannerTask>[
    const ui.PlannerTask(
      id: 'morning-prayer',
      label: 'Morning prayer',
      isDone: false,
    ),
    const ui.PlannerTask(
      id: 'daily-reading',
      label: 'Read today\'s passage',
      isDone: false,
    ),
    ui.PlannerTask(
      id: 'fasting-intent',
      label: day.fastStatus.isFastingDay
          ? 'Keep fasting with humility'
          : 'Practice gratitude and restraint',
      isDone: false,
    ),
  ];
  final event = day.feasts.isNotEmpty
      ? 'Feast: ${day.feasts.first.nameKey}'
      : null;
  return ui.PersonalDayPlanner(
    tasks: tasks,
    notes: day.fastStatus.notesKey,
    event: event,
  );
}

ui.SpiritualTracker _spiritualTracker() {
  return const ui.SpiritualTracker(
    habits: [
      ui.TrackerHabit(id: 'prayer', label: 'Prayer done', isDone: false),
      ui.TrackerHabit(id: 'bible', label: 'Bible read', isDone: false),
      ui.TrackerHabit(
        id: 'fasting',
        label: 'Fasting followed',
        isDone: false,
        isOptional: true,
      ),
      ui.TrackerHabit(
        id: 'church',
        label: 'Church attended',
        isDone: false,
        isOptional: true,
      ),
      ui.TrackerHabit(
        id: 'confession',
        label: 'Confession/communion',
        isDone: false,
        isOptional: true,
      ),
    ],
  );
}

List<String> _quickRules(bool isFastingDay) {
  if (!isFastingDay) {
    return const [
      'Eat with gratitude and avoid excess.',
      'Keep prayer and mercy at the center of the day.',
    ];
  }
  return const [
    'Traditional fast: plant-based meals, no animal products.',
    'Guidance varies. Follow your father of confession.',
  ];
}

ui.UpcomingDay _mapUpcomingDay(DayObservance item) {
  final feastLabel = item.feasts.isNotEmpty ? item.feasts.first.nameKey : null;
  final title = feastLabel != null
      ? 'Feast: $feastLabel'
      : item.fastStatus.isFastingDay
      ? 'Fasting Day'
      : 'Regular Day';
  final subtitle = item.fastStatus.isFastingDay
      ? item.fastStatus.seasonNameKey ?? 'Wed/Fri Fast'
      : 'No fasting';
  final badges = <String>[
    if (item.fastStatus.isFastingDay) 'FAST',
    if (item.feasts.isNotEmpty) 'FEAST',
    if (item.dailyReadings.isLoaded) 'READINGS',
  ];

  return ui.UpcomingDay(
    id: item.gregorianDateYmd,
    date: _shortGregorian(item.gregorianDateYmd),
    ethDate: _formatEthDay(item.ethDate),
    saint: feastLabel ?? 'Orthodox Day',
    label: title,
    subtitle: subtitle,
    badges: badges,
  );
}

List<ui.MonthSelectorItem> _monthChips(DateTime now) {
  final labels = <String>['Today'];
  for (var i = 0; i < 11; i++) {
    final date = DateTime(now.year, now.month + i, 1);
    labels.add(_monthAbbr(date.month));
  }
  return labels.map((label) => ui.MonthSelectorItem(label: label)).toList();
}

List<ui.ObservanceItem> _observances(DayObservance day) {
  final items = <ui.ObservanceItem>[
    ui.ObservanceItem(
      type: 'Fasting today',
      label: day.fastStatus.isFastingDay ? 'Yes' : 'No',
    ),
    ui.ObservanceItem(
      type: 'Type',
      label:
          day.fastStatus.seasonNameKey ??
          (day.fastStatus.isFastingDay ? 'Wed/Fri' : 'Regular day'),
    ),
  ];

  for (final reason in _fastReasonLabels(day.fastStatus.reasons)) {
    items.add(ui.ObservanceItem(type: 'Reason', label: reason));
  }

  if (day.fastStatus.isFastingDay) {
    items.add(
      ui.ObservanceItem(
        type: 'Note',
        label: day.fastStatus.notesKey ?? 'Follow parish guidance',
      ),
    );
  }

  return items;
}

List<String> _fastReasonLabels(List<String> reasons) {
  return reasons.map((reason) {
    switch (reason) {
      case 'FAST_SEASON':
        return 'Great Lent';
      case 'WED_FRI':
        return 'Weekly Wed/Fri';
      case 'GAHAD':
        return 'Gahad';
      default:
        return reason;
    }
  }).toList();
}

String? _topReasonLabel(FastStatusResult status, List<String> labels) {
  if (!status.isFastingDay) {
    return null;
  }
  if (status.seasonNameKey != null && status.seasonNameKey!.trim().isNotEmpty) {
    return status.seasonNameKey;
  }
  if (labels.isNotEmpty) {
    return labels.first;
  }
  return 'Wed/Fri';
}

String _monthAbbr(int month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return labels[(month - 1) % 12];
}

String _shortGregorian(String ymd) {
  final parts = ymd.split('-');
  if (parts.length != 3) {
    return ymd;
  }
  final month = int.tryParse(parts[1]) ?? 1;
  final day = int.tryParse(parts[2]) ?? 1;
  return '${_monthAbbr(month)} $day';
}

String _formatGregorian(DateTime date) {
  return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
}

String _formatEthDate(EthDate ethDate) {
  return '${_ethMonthName(ethDate.month)} ${ethDate.day}, ${ethDate.year} E.C.';
}

String _formatEthDateAmharic(EthDate ethDate) {
  return '${_ethMonthAmharic(ethDate.month)} ${ethDate.day}, ${ethDate.year}';
}

String _formatEthDay(EthDate ethDate) {
  return '${_ethMonthName(ethDate.month)} ${ethDate.day}';
}

String _ethMonthName(int month) {
  const names = [
    'Meskerem',
    'Tikimt',
    'Hedar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];
  return names[(month - 1).clamp(0, 12).toInt()];
}

String _ethMonthAmharic(int month) {
  const names = [
    'Meskerem',
    'Tikimt',
    'Hedar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];
  return names[(month - 1).clamp(0, 12).toInt()];
}

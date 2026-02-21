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

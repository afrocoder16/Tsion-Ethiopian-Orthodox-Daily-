import 'package:abushakir/abushakir.dart';

import 'calendar_engine_models.dart';

class CalendarEngine {
  static const String engineVersion = '1.0.0';
  static const String rulesetVersion = '1.0.0';

  static const int _offsetAbiyTsom = 14;
  static const int _offsetHosanna = 62;
  static const int _offsetSiklet = 67;
  static const int _offsetEaster = 69;
  static const int _offsetAscension = 108;
  static const int _offsetPentecost = 118;
  static const int _offsetApostlesStart = 119;

  DayObservance getDayObservance(DateTime gregorianDateLocal) {
    final normalized = _normalizeLocalDate(gregorianDateLocal);
    final eth = ethDateFromGregorian(normalized);
    final anchors = getAnchorsForYear(eth.year);
    final feasts = _feastsForDate(eth, anchors);
    final fastStatus = _fastStatusForDate(normalized, eth, anchors, feasts);
    final progress = _seasonProgress(eth, fastStatus.seasonStart, fastStatus.seasonEnd);
    return DayObservance(
      gregorianDateYmd: _formatYmd(normalized),
      ethDate: eth,
      weekdayKey: _weekdayName(normalized.weekday),
      evangelistKey: _evangelistDisplay(anchors.evangelistName),
      fastStatus: fastStatus,
      seasonProgress: progress,
      feasts: feasts,
      dailyReadings: const DailyReadingsData(
        morning: [],
        liturgy: [],
        evening: [],
        isLoaded: false,
      ),
      saintsPreview: _saintsFromFeasts(feasts),
      movableSignals: {
        'nenewe': anchors.nenewe,
        'easter': anchors.easter,
        'pentecost': anchors.pentecost,
      },
      engineVersion: engineVersion,
      rulesetVersion: rulesetVersion,
    );
  }

  MonthObservance getMonthObservance(int ethYear, int ethMonth) {
    final maxDay = _daysInEthMonth(ethYear, ethMonth);
    final days = <MonthObservanceDay>[];
    for (var day = 1; day <= maxDay; day++) {
      final eth = EthDate(year: ethYear, month: ethMonth, day: day);
      final gregorian = gregorianFromEthDate(eth);
      final observance = getDayObservance(gregorian);
      final topFeast = observance.feasts.isEmpty
          ? null
          : (observance.feasts.toList()
                  ..sort((a, b) => b.priority.compareTo(a.priority)))
                .first
                .id;
      days.add(
        MonthObservanceDay(
          ethDay: day,
          ethDateKey: eth.key,
          gregorianDateYmd: observance.gregorianDateYmd,
          isFastingDay: observance.fastStatus.isFastingDay,
          feastCount: observance.feasts.length,
          topFeastId: topFeast,
        ),
      );
    }
    return MonthObservance(ethYear: ethYear, ethMonth: ethMonth, days: days);
  }

  List<DayObservance> getRangeObservance(DateTime startDateLocal, int days) {
    final normalized = _normalizeLocalDate(startDateLocal);
    final result = <DayObservance>[];
    for (var i = 0; i < days; i++) {
      final target = normalized.add(Duration(days: i));
      result.add(getDayObservance(target));
    }
    return result;
  }

  CalendarYearAnchors getAnchorsForYear(int ethYear) {
    final bahire = BahireHasab(year: ethYear);
    final neneweMap = bahire.nenewe;
    final nenewe = _ethDateFromBahireMap(ethYear, neneweMap);
    final abiyTsomStart = _addEthDays(nenewe, _offsetAbiyTsom);
    final hosanna = _addEthDays(nenewe, _offsetHosanna);
    final siklet = _addEthDays(nenewe, _offsetSiklet);
    final easter = _addEthDays(nenewe, _offsetEaster);
    final ascension = _addEthDays(nenewe, _offsetAscension);
    final pentecost = _addEthDays(nenewe, _offsetPentecost);
    final apostlesFastStart = _addEthDays(nenewe, _offsetApostlesStart);
    return CalendarYearAnchors(
      ethYear: ethYear,
      evangelistName: bahire.getEvangelist(returnName: true),
      nenewe: nenewe,
      abiyTsomStart: abiyTsomStart,
      hosanna: hosanna,
      siklet: siklet,
      easter: easter,
      ascension: ascension,
      pentecost: pentecost,
      apostlesFastStart: apostlesFastStart,
    );
  }

  EthDate ethDateFromGregorian(DateTime gregorianDateLocal) {
    final noon = _normalizeLocalDate(gregorianDateLocal);
    final et = EtDatetime.fromMillisecondsSinceEpoch(
      noon.millisecondsSinceEpoch,
    );
    return EthDate(year: et.year, month: et.month, day: et.day);
  }

  DateTime gregorianFromEthDate(EthDate ethDate) {
    final et = EtDatetime(
      year: ethDate.year,
      month: ethDate.month,
      day: ethDate.day,
      hour: 12,
    );
    final gregorian = DateTime.fromMillisecondsSinceEpoch(et.moment);
    return _normalizeLocalDate(gregorian);
  }

  FastStatusResult _fastStatusForDate(
    DateTime gregorian,
    EthDate ethDate,
    CalendarYearAnchors anchors,
    List<FeastInfo> feasts,
  ) {
    final reasons = <String>[];
    String? seasonId;
    String? seasonName;
    EthDate? seasonStart;
    EthDate? seasonEnd;
    String? notesKey;

    final weeklyFast =
        gregorian.weekday == DateTime.wednesday ||
        gregorian.weekday == DateTime.friday;
    final inFiftyDaysWindow = _isInRange(
      ethDate,
      anchors.easter,
      anchors.pentecost,
    );
    final christmasOrEpiphany =
        _isSameEthDate(ethDate, const EthDate(year: 0, month: 4, day: 29)) ||
        _isSameEthDate(ethDate, const EthDate(year: 0, month: 5, day: 11));
    if (weeklyFast && !inFiftyDaysWindow && !christmasOrEpiphany) {
      reasons.add('WED_FRI');
    }

    final neneweEnd = _addEthDays(anchors.nenewe, 2);
    if (_isInRange(ethDate, anchors.nenewe, neneweEnd)) {
      reasons.add('FAST_SEASON');
      seasonId = 'NENEWE';
      seasonName = 'Nineveh Fast';
      seasonStart = anchors.nenewe;
      seasonEnd = neneweEnd;
    }

    final greatLentEnd = _addEthDays(anchors.easter, -1);
    if (_isInRange(ethDate, anchors.abiyTsomStart, greatLentEnd)) {
      reasons.add('FAST_SEASON');
      seasonId = 'GREAT_LENT';
      seasonName = 'Great Lent';
      seasonStart = anchors.abiyTsomStart;
      seasonEnd = greatLentEnd;
    }

    final apostlesEnd = EthDate(year: ethDate.year, month: 11, day: 5);
    if (_isInRange(ethDate, anchors.apostlesFastStart, apostlesEnd)) {
      reasons.add('FAST_SEASON');
      seasonId = 'APOSTLES_FAST';
      seasonName = 'Apostles Fast';
      seasonStart = anchors.apostlesFastStart;
      seasonEnd = apostlesEnd;
    }

    final adventStart = EthDate(year: ethDate.year, month: 3, day: 15);
    final adventEnd = EthDate(year: ethDate.year, month: 4, day: 28);
    if (_isInRange(ethDate, adventStart, adventEnd)) {
      reasons.add('FAST_SEASON');
      seasonId = 'ADVENT_FAST';
      seasonName = 'Advent Fast';
      seasonStart = adventStart;
      seasonEnd = adventEnd;
    }

    final filsetaStart = EthDate(year: ethDate.year, month: 12, day: 1);
    final filsetaEnd = EthDate(year: ethDate.year, month: 12, day: 15);
    if (_isInRange(ethDate, filsetaStart, filsetaEnd)) {
      reasons.add('FAST_SEASON');
      seasonId = 'FILSETA';
      seasonName = 'Filseta';
      seasonStart = filsetaStart;
      seasonEnd = filsetaEnd;
    }

    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 4, day: 28),
    )) {
      reasons.add('GAHAD');
      seasonId = 'GAHAD_GENNA';
      seasonName = 'Gahad of Genna';
      seasonStart = EthDate(year: ethDate.year, month: 4, day: 28);
      seasonEnd = seasonStart;
    }
    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 5, day: 10),
    )) {
      reasons.add('GAHAD');
      seasonId = 'GAHAD_TIMKET';
      seasonName = 'Gahad of Timket';
      seasonStart = EthDate(year: ethDate.year, month: 5, day: 10);
      seasonEnd = seasonStart;
    }

    if (reasons.isNotEmpty) {
      notesKey = 'follow_confessor_guidance';
    } else if (feasts.isNotEmpty) {
      notesKey = 'feast_day';
    }

    return FastStatusResult(
      isFastingDay: reasons.isNotEmpty,
      reasons: reasons.toSet().toList(),
      seasonId: seasonId,
      seasonNameKey: seasonName,
      seasonStart: seasonStart,
      seasonEnd: seasonEnd,
      notesKey: notesKey,
    );
  }

  List<FeastInfo> _feastsForDate(EthDate ethDate, CalendarYearAnchors anchors) {
    final feasts = <FeastInfo>[];
    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 1, day: 17),
    )) {
      feasts.add(
        const FeastInfo(
          id: 'MESKEL',
          nameKey: 'Meskel',
          kind: 'FIXED',
          priority: 90,
        ),
      );
    }
    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 4, day: 29),
    )) {
      feasts.add(
        const FeastInfo(
          id: 'GENNA',
          nameKey: 'Genna',
          kind: 'FIXED',
          priority: 100,
        ),
      );
    }
    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 5, day: 11),
    )) {
      feasts.add(
        const FeastInfo(
          id: 'TIMKET',
          nameKey: 'Timket',
          kind: 'FIXED',
          priority: 100,
        ),
      );
    }
    if (_isSameEthDate(
      ethDate,
      EthDate(year: ethDate.year, month: 12, day: 16),
    )) {
      feasts.add(
        const FeastInfo(
          id: 'DORMITION_FEAST',
          nameKey: 'Dormition Feast',
          kind: 'FIXED',
          priority: 80,
        ),
      );
    }

    if (_isSameEthDate(ethDate, anchors.hosanna)) {
      feasts.add(
        const FeastInfo(
          id: 'HOSANNA',
          nameKey: 'Hosanna',
          kind: 'MOVABLE',
          priority: 95,
        ),
      );
    }
    if (_isSameEthDate(ethDate, anchors.siklet)) {
      feasts.add(
        const FeastInfo(
          id: 'SIKLET',
          nameKey: 'Siklet',
          kind: 'MOVABLE',
          priority: 98,
        ),
      );
    }
    if (_isSameEthDate(ethDate, anchors.easter)) {
      feasts.add(
        const FeastInfo(
          id: 'EASTER',
          nameKey: 'Easter',
          kind: 'MOVABLE',
          priority: 120,
        ),
      );
    }
    if (_isSameEthDate(ethDate, anchors.ascension)) {
      feasts.add(
        const FeastInfo(
          id: 'ASCENSION',
          nameKey: 'Ascension',
          kind: 'MOVABLE',
          priority: 94,
        ),
      );
    }
    if (_isSameEthDate(ethDate, anchors.pentecost)) {
      feasts.add(
        const FeastInfo(
          id: 'PENTECOST',
          nameKey: 'Pentecost',
          kind: 'MOVABLE',
          priority: 96,
        ),
      );
    }

    return feasts;
  }

  EthDate _ethDateFromBahireMap(int year, Map<String, dynamic> raw) {
    final monthName = '${raw['month']}';
    final date = raw['date'] as int;
    final monthLookup = <String, int>{};
    for (var month = 1; month <= 13; month++) {
      final et = EtDatetime(year: year, month: month, day: 1);
      final geez = et.monthGeez;
      if (geez != null && geez.isNotEmpty) {
        monthLookup[geez] = month;
      }
    }
    final month = monthLookup[monthName] ?? 1;
    return EthDate(year: year, month: month, day: date);
  }

  EthDate _addEthDays(EthDate start, int delta) {
    var year = start.year;
    var month = start.month;
    var day = start.day;
    var remaining = delta;
    if (remaining >= 0) {
      while (remaining > 0) {
        final maxDay = _daysInEthMonth(year, month);
        if (day < maxDay) {
          day++;
        } else {
          day = 1;
          if (month < 13) {
            month++;
          } else {
            month = 1;
            year++;
          }
        }
        remaining--;
      }
      return EthDate(year: year, month: month, day: day);
    }

    remaining = -remaining;
    while (remaining > 0) {
      if (day > 1) {
        day--;
      } else {
        if (month > 1) {
          month--;
        } else {
          month = 13;
          year--;
        }
        day = _daysInEthMonth(year, month);
      }
      remaining--;
    }
    return EthDate(year: year, month: month, day: day);
  }

  int _daysInEthMonth(int year, int month) {
    if (month <= 12) {
      return 30;
    }
    return year % 4 == 3 ? 6 : 5;
  }

  bool _isInRange(EthDate target, EthDate start, EthDate end) {
    return _compareEthDate(target, start) >= 0 &&
        _compareEthDate(target, end) <= 0;
  }

  int _compareEthDate(EthDate a, EthDate b) {
    final year = a.year.compareTo(b.year);
    if (year != 0) {
      return year;
    }
    final month = a.month.compareTo(b.month);
    if (month != 0) {
      return month;
    }
    return a.day.compareTo(b.day);
  }

  bool _isSameEthDate(EthDate a, EthDate b) {
    if (b.year == 0) {
      return a.month == b.month && a.day == b.day;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  SeasonProgressData? _seasonProgress(EthDate target, EthDate? start, EthDate? end) {
    if (start == null || end == null) {
      return null;
    }
    if (!_isInRange(target, start, end)) {
      return null;
    }
    final dayIndex = _dayDistance(start, target) + 1;
    final total = _dayDistance(start, end) + 1;
    final remaining = total - dayIndex;
    return SeasonProgressData(
      dayIndex: dayIndex,
      totalDays: total,
      daysRemaining: remaining < 0 ? 0 : remaining,
    );
  }

  int _dayDistance(EthDate from, EthDate to) {
    var current = from;
    var days = 0;
    while (!_isSameEthDate(current, to)) {
      current = _addEthDays(current, 1);
      days++;
      if (days > 500) {
        break;
      }
    }
    return days;
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(weekday - 1) % 7];
  }

  String _evangelistDisplay(String raw) {
    const map = {
      'ዮሐንስ': 'John (ዮሐንስ)',
      'ማቴዎስ': 'Matthew (ማቴዎስ)',
      'ማርቆስ': 'Mark (ማርቆስ)',
      'ሉቃስ': 'Luke (ሉቃስ)',
    };
    return map[raw] ?? raw;
  }

  List<SaintPreviewData> _saintsFromFeasts(List<FeastInfo> feasts) {
    if (feasts.isEmpty) {
      return const <SaintPreviewData>[];
    }
    return feasts
        .map(
          (feast) => SaintPreviewData(
            nameKey: feast.nameKey,
            shortSnippet: 'Tap to read in Synaxarium.',
          ),
        )
        .toList();
  }

  DateTime _normalizeLocalDate(DateTime localDate) {
    return DateTime(localDate.year, localDate.month, localDate.day, 12);
  }

  String _formatYmd(DateTime localDate) {
    final date = DateTime(localDate.year, localDate.month, localDate.day);
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

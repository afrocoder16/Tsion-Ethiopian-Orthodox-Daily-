class EthDate {
  const EthDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {'year': year, 'month': month, 'day': day};

  static EthDate fromJson(Map<String, dynamic> json) => EthDate(
    year: json['year'] as int,
    month: json['month'] as int,
    day: json['day'] as int,
  );
}

class FeastInfo {
  const FeastInfo({
    required this.id,
    required this.nameKey,
    required this.kind,
    required this.priority,
  });

  final String id;
  final String nameKey;
  final String kind;
  final int priority;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameKey': nameKey,
    'kind': kind,
    'priority': priority,
  };

  static FeastInfo fromJson(Map<String, dynamic> json) => FeastInfo(
    id: json['id'] as String,
    nameKey: json['nameKey'] as String,
    kind: json['kind'] as String,
    priority: json['priority'] as int,
  );
}

class FastStatusResult {
  const FastStatusResult({
    required this.isFastingDay,
    required this.reasons,
    this.seasonId,
    this.seasonNameKey,
    this.seasonStart,
    this.seasonEnd,
    this.notesKey,
  });

  final bool isFastingDay;
  final List<String> reasons;
  final String? seasonId;
  final String? seasonNameKey;
  final EthDate? seasonStart;
  final EthDate? seasonEnd;
  final String? notesKey;

  Map<String, dynamic> toJson() => {
    'isFastingDay': isFastingDay,
    'reasons': reasons,
    'seasonId': seasonId,
    'seasonNameKey': seasonNameKey,
    'seasonStart': seasonStart?.toJson(),
    'seasonEnd': seasonEnd?.toJson(),
    'notesKey': notesKey,
  };

  static FastStatusResult fromJson(Map<String, dynamic> json) =>
      FastStatusResult(
        isFastingDay: json['isFastingDay'] as bool,
        reasons: (json['reasons'] as List<dynamic>).cast<String>(),
        seasonId: json['seasonId'] as String?,
        seasonNameKey: json['seasonNameKey'] as String?,
        seasonStart: json['seasonStart'] == null
            ? null
            : EthDate.fromJson(json['seasonStart'] as Map<String, dynamic>),
        seasonEnd: json['seasonEnd'] == null
            ? null
            : EthDate.fromJson(json['seasonEnd'] as Map<String, dynamic>),
        notesKey: json['notesKey'] as String?,
      );
}

class DayObservance {
  const DayObservance({
    required this.gregorianDateYmd,
    required this.ethDate,
    required this.weekdayKey,
    required this.evangelistKey,
    required this.fastStatus,
    this.seasonProgress,
    required this.feasts,
    required this.dailyReadings,
    required this.saintsPreview,
    required this.movableSignals,
    required this.engineVersion,
    required this.rulesetVersion,
  });

  final String gregorianDateYmd;
  final EthDate ethDate;
  final String weekdayKey;
  final String evangelistKey;
  final FastStatusResult fastStatus;
  final SeasonProgressData? seasonProgress;
  final List<FeastInfo> feasts;
  final DailyReadingsData dailyReadings;
  final List<SaintPreviewData> saintsPreview;
  final Map<String, EthDate> movableSignals;
  final String engineVersion;
  final String rulesetVersion;

  Map<String, dynamic> toJson() => {
    'gregorianDateYmd': gregorianDateYmd,
    'ethDate': ethDate.toJson(),
    'weekdayKey': weekdayKey,
    'evangelistKey': evangelistKey,
    'fastStatus': fastStatus.toJson(),
    'seasonProgress': seasonProgress?.toJson(),
    'feasts': feasts.map((item) => item.toJson()).toList(),
    'dailyReadings': dailyReadings.toJson(),
    'saintsPreview': saintsPreview.map((item) => item.toJson()).toList(),
    'movableSignals': movableSignals.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'engineVersion': engineVersion,
    'rulesetVersion': rulesetVersion,
  };

  static DayObservance fromJson(Map<String, dynamic> json) => DayObservance(
    gregorianDateYmd: json['gregorianDateYmd'] as String,
    ethDate: EthDate.fromJson(json['ethDate'] as Map<String, dynamic>),
    weekdayKey: json['weekdayKey'] as String,
    evangelistKey: json['evangelistKey'] as String,
    fastStatus: FastStatusResult.fromJson(
      json['fastStatus'] as Map<String, dynamic>,
    ),
    seasonProgress: json['seasonProgress'] == null
        ? null
        : SeasonProgressData.fromJson(
            json['seasonProgress'] as Map<String, dynamic>,
          ),
    feasts: (json['feasts'] as List<dynamic>)
        .map((item) => FeastInfo.fromJson(item as Map<String, dynamic>))
        .toList(),
    dailyReadings: DailyReadingsData.fromJson(
      json['dailyReadings'] as Map<String, dynamic>,
    ),
    saintsPreview: (json['saintsPreview'] as List<dynamic>)
        .map((item) => SaintPreviewData.fromJson(item as Map<String, dynamic>))
        .toList(),
    movableSignals: (json['movableSignals'] as Map<String, dynamic>).map(
      (key, value) =>
          MapEntry(key, EthDate.fromJson(value as Map<String, dynamic>)),
    ),
    engineVersion: json['engineVersion'] as String,
    rulesetVersion: json['rulesetVersion'] as String,
  );
}

class SeasonProgressData {
  const SeasonProgressData({
    required this.dayIndex,
    required this.totalDays,
    required this.daysRemaining,
  });

  final int dayIndex;
  final int totalDays;
  final int daysRemaining;

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'totalDays': totalDays,
        'daysRemaining': daysRemaining,
      };

  static SeasonProgressData fromJson(Map<String, dynamic> json) =>
      SeasonProgressData(
        dayIndex: json['dayIndex'] as int,
        totalDays: json['totalDays'] as int,
        daysRemaining: json['daysRemaining'] as int,
      );
}

class DailyReadingsData {
  const DailyReadingsData({
    required this.morning,
    required this.liturgy,
    required this.evening,
    required this.isLoaded,
  });

  final List<String> morning;
  final List<String> liturgy;
  final List<String> evening;
  final bool isLoaded;

  Map<String, dynamic> toJson() => {
        'morning': morning,
        'liturgy': liturgy,
        'evening': evening,
        'isLoaded': isLoaded,
      };

  static DailyReadingsData fromJson(Map<String, dynamic> json) =>
      DailyReadingsData(
        morning: (json['morning'] as List<dynamic>).cast<String>(),
        liturgy: (json['liturgy'] as List<dynamic>).cast<String>(),
        evening: (json['evening'] as List<dynamic>).cast<String>(),
        isLoaded: json['isLoaded'] as bool,
      );
}

class SaintPreviewData {
  const SaintPreviewData({
    required this.nameKey,
    required this.shortSnippet,
  });

  final String nameKey;
  final String shortSnippet;

  Map<String, dynamic> toJson() => {
        'nameKey': nameKey,
        'shortSnippet': shortSnippet,
      };

  static SaintPreviewData fromJson(Map<String, dynamic> json) => SaintPreviewData(
        nameKey: json['nameKey'] as String,
        shortSnippet: json['shortSnippet'] as String,
      );
}

class MonthObservanceDay {
  const MonthObservanceDay({
    required this.ethDay,
    required this.ethDateKey,
    required this.gregorianDateYmd,
    required this.isFastingDay,
    required this.feastCount,
    this.topFeastId,
  });

  final int ethDay;
  final String ethDateKey;
  final String gregorianDateYmd;
  final bool isFastingDay;
  final int feastCount;
  final String? topFeastId;
}

class MonthObservance {
  const MonthObservance({
    required this.ethYear,
    required this.ethMonth,
    required this.days,
  });

  final int ethYear;
  final int ethMonth;
  final List<MonthObservanceDay> days;
}

class CalendarYearAnchors {
  const CalendarYearAnchors({
    required this.ethYear,
    required this.evangelistName,
    required this.nenewe,
    required this.abiyTsomStart,
    required this.hosanna,
    required this.siklet,
    required this.easter,
    required this.ascension,
    required this.pentecost,
    required this.apostlesFastStart,
  });

  final int ethYear;
  final String evangelistName;
  final EthDate nenewe;
  final EthDate abiyTsomStart;
  final EthDate hosanna;
  final EthDate siklet;
  final EthDate easter;
  final EthDate ascension;
  final EthDate pentecost;
  final EthDate apostlesFastStart;
}

import 'dart:convert';

import '../../calendar/calendar_engine.dart';
import '../../calendar/calendar_engine_models.dart';
import '../../calendar/calendar_observance_store.dart';
import '../../db/app_database.dart';
import '../celebrations_repository.dart';
import '../calendar_day_detail_repositories.dart';
import '../saints_repository.dart';

class DbCalendarDayDetailRepository implements CalendarDayDetailRepository {
  DbCalendarDayDetailRepository({
    required this.db,
    required this.engine,
    required this.celebrationsRepository,
    required this.saintsRepository,
  });

  final AppDatabase db;
  final CalendarEngine engine;
  final CelebrationsRepository celebrationsRepository;
  final SaintsRepository saintsRepository;

  static const String _dayDetailDatasetVersion = '1.0.0';

  @override
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey) async {
    final target = _parseDateKey(dateKey);
    final store = CalendarObservanceStore(db: db, engine: engine);
    final day = await store.getByGregorianDate(target);
    final cacheKey = _cacheKey(day.ethDate.key);
    final cached = await _readCache(cacheKey);
    if (cached != null) {
      return cached;
    }
    final bahireStats = engine.getBahireHasabStatsForYear(day.ethDate.year);
    final celebrations = await celebrationsRepository.fetchCelebrationsForDay(
      dayObservance: day,
    );
    final saints = await saintsRepository.fetchSaintsForDate(day.ethDate);
    final lents = await celebrationsRepository.fetchLentsForDay(
      dayObservance: day,
    );

    final observances = <CalendarObservance>[];
    if (day.fastStatus.isFastingDay) {
      observances.add(CalendarObservance(label: 'Fasting today', value: 'Yes'));
      observances.add(
        CalendarObservance(
          label: 'Type',
          value: day.fastStatus.seasonNameKey ?? 'Fasting day',
        ),
      );
    }
    for (final reason in day.fastStatus.reasons) {
      observances.add(CalendarObservance(label: 'Reason', value: reason));
    }
    if (observances.isEmpty) {
      observances.add(
        const CalendarObservance(label: 'Day', value: 'Regular day'),
      );
    }

    final state = CalendarDayDetailState(
      dateKey: day.gregorianDateYmd,
      ethiopianDate: day.ethDate.key,
      gregorianDate: day.gregorianDateYmd,
      weekday: day.weekdayKey,
      dayObservance: day,
      bahireTitle: 'Bahire Hasab',
      bahireDescription: 'Orthodox day observance details.',
      bahireHasabStats: bahireStats,
      observances: observances,
      celebrations: celebrations,
      saints: saints,
      lents: lents,
    );
    await _writeCache(cacheKey, state);
    return state;
  }

  DateTime _parseDateKey(String dateKey) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateKey);
    if (match == null) {
      return DateTime.now();
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return DateTime(year, month, day, 12);
  }

  String _cacheKey(String ethDateKey) {
    return 'day_detail_cache:${CalendarEngine.engineVersion}:${CalendarEngine.rulesetVersion}:$_dayDetailDatasetVersion:$ethDateKey';
  }

  Future<CalendarDayDetailState?> _readCache(String key) async {
    try {
      final raw = await db.metaDao.readMeta(key);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return _decodeState(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String key, CalendarDayDetailState state) async {
    try {
      await db.metaDao.upsertMeta(key, jsonEncode(_encodeState(state)));
    } catch (_) {
      // Ignore cache write failures.
    }
  }

  Map<String, dynamic> _encodeState(CalendarDayDetailState state) {
    return {
      'dateKey': state.dateKey,
      'ethiopianDate': state.ethiopianDate,
      'gregorianDate': state.gregorianDate,
      'weekday': state.weekday,
      'dayObservance': state.dayObservance.toJson(),
      'bahireTitle': state.bahireTitle,
      'bahireDescription': state.bahireDescription,
      'bahireHasabStats': state.bahireHasabStats.toJson(),
      'observances': state.observances
          .map((item) => {'label': item.label, 'value': item.value})
          .toList(),
      'celebrations': state.celebrations.map((item) => item.toJson()).toList(),
      'saints': state.saints.map((item) => item.toJson()).toList(),
      'lents': state.lents.map((item) => item.toJson()).toList(),
    };
  }

  CalendarDayDetailState _decodeState(Map<String, dynamic> json) {
    final observancesRaw = json['observances'] as List<dynamic>? ?? const [];
    return CalendarDayDetailState(
      dateKey: json['dateKey'] as String,
      ethiopianDate: json['ethiopianDate'] as String,
      gregorianDate: json['gregorianDate'] as String,
      weekday: json['weekday'] as String,
      dayObservance: DayObservance.fromJson(
        json['dayObservance'] as Map<String, dynamic>,
      ),
      bahireTitle: json['bahireTitle'] as String,
      bahireDescription: json['bahireDescription'] as String,
      bahireHasabStats: BahireHasabStats.fromJson(
        json['bahireHasabStats'] as Map<String, dynamic>,
      ),
      observances: observancesRaw
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CalendarObservance(
              label: '${item['label'] ?? ''}',
              value: '${item['value'] ?? ''}',
            ),
          )
          .toList(),
      celebrations: (json['celebrations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Celebration.fromJson(item))
          .toList(),
      saints: (json['saints'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => SaintSummary.fromJson(item))
          .toList(),
      lents: (json['lents'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => LentSummary.fromJson(item))
          .toList(),
    );
  }
}

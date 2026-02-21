import 'dart:convert';

import '../db/app_database.dart';
import 'calendar_engine.dart';
import 'calendar_engine_models.dart';

class CalendarObservanceStore {
  CalendarObservanceStore({required this.db, required this.engine});

  final AppDatabase db;
  final CalendarEngine engine;

  Future<DayObservance> getByGregorianDate(DateTime dateLocal) async {
    final eth = engine.ethDateFromGregorian(dateLocal);
    final cacheKey = _cacheKeyForEthDate(eth);
    try {
      final raw = await db.metaDao.readMeta(cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final cached = DayObservance.fromJson(decoded);
        if (cached.engineVersion == CalendarEngine.engineVersion &&
            cached.rulesetVersion == CalendarEngine.rulesetVersion) {
          return cached;
        }
      }
    } catch (_) {
      // Ignore cache read failures and recompute.
    }

    final computed = engine.getDayObservance(dateLocal);
    try {
      await db.metaDao.upsertMeta(cacheKey, jsonEncode(computed.toJson()));
    } catch (_) {
      // Ignore cache write failures.
    }
    return computed;
  }

  Future<DayObservance> getByEthDate(EthDate ethDate) async {
    final gregorian = engine.gregorianFromEthDate(ethDate);
    return getByGregorianDate(gregorian);
  }

  Future<List<DayObservance>> getRange(
    DateTime startDateLocal,
    int days,
  ) async {
    final result = <DayObservance>[];
    final normalized = DateTime(
      startDateLocal.year,
      startDateLocal.month,
      startDateLocal.day,
      12,
    );
    for (var i = 0; i < days; i++) {
      final date = normalized.add(Duration(days: i));
      result.add(await getByGregorianDate(date));
    }
    return result;
  }

  String _cacheKeyForEthDate(EthDate ethDate) {
    return 'observance_cache:${CalendarEngine.engineVersion}:${CalendarEngine.rulesetVersion}:${ethDate.key}';
  }
}

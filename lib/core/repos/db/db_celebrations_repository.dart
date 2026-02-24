import 'dart:convert';

import 'package:flutter/services.dart';

import '../../calendar/calendar_engine.dart';
import '../../calendar/calendar_engine_models.dart';
import '../celebrations_repository.dart';

class DbCelebrationsRepository implements CelebrationsRepository {
  DbCelebrationsRepository({
    required this.engine,
    this.assetPath = 'assets/data/calendar_dataset.json',
  });

  final CalendarEngine engine;
  final String assetPath;
  Map<String, dynamic>? _dataset;
  final Map<int, List<Celebration>> _movableCache = {};

  @override
  Future<List<Celebration>> fetchCelebrationsForDay({
    required DayObservance dayObservance,
  }) async {
    final data = await _loadDataset();
    final eth = dayObservance.ethDate;
    final results = <Celebration>[];

    results.addAll(_monthlyCelebrations(data, eth));
    results.addAll(_annualFeasts(data, eth));

    final movable = _movableCache.putIfAbsent(
      eth.year,
      () => engine.getMovableCelebrationsForYear(eth.year),
    );
    results.addAll(movable.where((item) => item.ethDateKey == eth.key));

    final deduped = <String, Celebration>{};
    for (final item in results) {
      final key = item.title.trim().toLowerCase();
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = item;
        continue;
      }
      final incomingAnnual = _isAnnual(item.subtitle);
      final existingAnnual = _isAnnual(existing.subtitle);
      if (incomingAnnual && !existingAnnual) {
        deduped[key] = item;
      }
    }
    return deduped.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  @override
  Future<List<LentSummary>> fetchLentsForDay({
    required DayObservance dayObservance,
  }) async {
    final data = await _loadDataset();
    final lents = <LentSummary>[];
    final canonical =
        (((data['fasts_and_lents']
                as Map<String, dynamic>?)?['canonical_7_fasts'])
            as List<dynamic>? ??
        const []);
    final weekly =
        ((data['fasts_and_lents']
                as Map<String, dynamic>?)?['weekly_fast_rule'])
            as Map<String, dynamic>?;

    String? matchedId;
    final seasonId = dayObservance.fastStatus.seasonId ?? '';
    switch (seasonId) {
      case 'GREAT_LENT':
        matchedId = 'abiy_tsom_hudadi';
      case 'APOSTLES_FAST':
        matchedId = 'apostles_fast';
      case 'FILSETA':
        matchedId = 'assumption_fast';
      case 'ADVENT_FAST':
        matchedId = 'christmas_fast_advent';
      case 'NENEWE':
        matchedId = 'fast_of_nineveh';
      case 'GAHAD_GENNA':
        matchedId = 'gahad_christmas';
      case 'GAHAD_TIMKET':
        matchedId = 'gahad_timket';
    }

    if (matchedId != null) {
      for (final item in canonical) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        if ('${item['id']}' != matchedId) {
          continue;
        }
        lents.add(
          LentSummary(
            id: '${item['id']}',
            name: '${item['name_en']}',
            status: 'Active today',
          ),
        );
      }
    }

    if (dayObservance.fastStatus.reasons.contains('WED_FRI') &&
        weekly != null) {
      lents.add(
        LentSummary(
          id: '${weekly['id'] ?? 'weekly_wed_fri'}',
          name: '${weekly['name_en'] ?? 'Weekly Wednesday and Friday fast'}',
          status: 'Active today',
        ),
      );
    }

    if (dayObservance.fastStatus.isFastingDay && lents.isEmpty) {
      lents.add(
        LentSummary(
          id: 'fasting_day',
          name: dayObservance.fastStatus.seasonNameKey ?? 'Fasting Day',
          status: 'Active today',
        ),
      );
    }

    return lents;
  }

  List<Celebration> _monthlyCelebrations(
    Map<String, dynamic> data,
    EthDate eth,
  ) {
    final root =
        (data['monthly_recurring_commemorations']
            as Map<String, dynamic>?)?['days'];
    final days = root as List<dynamic>? ?? const [];
    final out = <Celebration>[];
    for (final dayBlock in days) {
      if (dayBlock is! Map<String, dynamic>) {
        continue;
      }
      final dayNum = int.tryParse('${dayBlock['eth_day']}');
      if (dayNum != eth.day) {
        continue;
      }
      final items = dayBlock['items'] as List<dynamic>? ?? const [];
      for (final item in items) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final name = '${item['name_en'] ?? ''}'.trim();
        if (name.isEmpty) {
          continue;
        }
        out.add(
          Celebration(
            id: '${item['id'] ?? _slug(name)}',
            title: name,
            subtitle: '${item['category'] ?? 'Commemoration'}',
            ethDateKey: eth.key,
          ),
        );
      }
      break;
    }
    return out;
  }

  List<Celebration> _annualFeasts(Map<String, dynamic> data, EthDate eth) {
    final root = (data['annual_feasts'] as Map<String, dynamic>?)?['items'];
    final items = root as List<dynamic>? ?? const [];
    final out = <Celebration>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final monthName = '${raw['eth_month'] ?? ''}'.trim();
      final day = int.tryParse('${raw['eth_day']}');
      if (monthName.isEmpty || day == null) {
        continue;
      }
      if (!_sameEthMonth(monthName, eth.month) || day != eth.day) {
        continue;
      }
      final name = '${raw['name_en'] ?? ''}'.trim();
      if (name.isEmpty) {
        continue;
      }
      out.add(
        Celebration(
          id: '${raw['id'] ?? _slug(name)}',
          title: name,
          subtitle: 'Annual feast',
          ethDateKey: eth.key,
        ),
      );
    }
    return out;
  }

  bool _sameEthMonth(String jsonName, int month) {
    final normalized = jsonName.trim().toLowerCase();
    final monthNames = <int, List<String>>{
      1: ['meskerem'],
      2: ['tikimt'],
      3: ['hidar', 'hidar'],
      4: ['tahsas'],
      5: ['tir', 'ter'],
      6: ['yekatit'],
      7: ['megabit'],
      8: ['miyazia'],
      9: ['ginbot'],
      10: ['sene'],
      11: ['hamle'],
      12: ['nehase'],
      13: ['pagumen'],
    };
    return monthNames[month]?.contains(normalized) ?? false;
  }

  Future<Map<String, dynamic>> _loadDataset() async {
    final cached = _dataset;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _dataset = decoded;
    return decoded;
  }

  String _slug(String value) {
    final lower = value.trim().toLowerCase();
    if (lower.isEmpty) {
      return 'item';
    }
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  bool _isAnnual(String subtitle) {
    return subtitle.trim().toLowerCase() == 'annual feast';
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../../calendar/calendar_engine_models.dart';
import '../saints_repository.dart';

class DbSaintsRepository implements SaintsRepository {
  DbSaintsRepository({
    this.assetPath = 'assets/data/calendar_dataset.json',
    this.readingPath = 'assets/data/synaxarium_word_readings.json',
  });

  final String assetPath;
  final String readingPath;
  Map<String, dynamic>? _dataset;
  Map<String, dynamic>? _readings;

  @override
  Future<List<SaintSummary>> fetchSaintsForDate(EthDate ethDate) async {
    final data = await _loadDataset();
    final override = _annualPrimaryOverride(data, ethDate);
    if (override != null) {
      return [override];
    }
    final primary = _coreMonthlyPrimary(data, ethDate);
    if (primary != null) {
      return [primary];
    }
    return _fallbackMonthlyItems(data, ethDate);
  }

  Future<Map<String, dynamic>> _loadDataset() async {
    final cached = _dataset;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final readingRaw = await rootBundle.loadString(readingPath);
    _readings = jsonDecode(readingRaw) as Map<String, dynamic>;
    _dataset = decoded;
    return decoded;
  }

  SaintSummary? _annualPrimaryOverride(
    Map<String, dynamic> data,
    EthDate ethDate,
  ) {
    final overrides =
        (data['annual_override_primary'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>();
    for (final item in overrides) {
      final day = int.tryParse('${item['eth_day']}');
      final month = '${item['eth_month'] ?? ''}'.trim();
      if (day == null || day != ethDate.day) {
        continue;
      }
      if (!_sameEthMonth(month, ethDate.month)) {
        continue;
      }
      final name = '${item['name_en'] ?? ''}'.trim();
      if (name.isEmpty) {
        continue;
      }
      return SaintSummary(
        id: 'annual_${_slug(name)}',
        name: name,
        snippet: _synaxariumSnippet(ethDate.day, fallback: 'Annual override primary'),
      );
    }
    return null;
  }

  SaintSummary? _coreMonthlyPrimary(Map<String, dynamic> data, EthDate ethDate) {
    final primaryDays =
        (data['core_monthly_primary_days'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>();
    for (final item in primaryDays) {
      final day = int.tryParse('${item['eth_day']}');
      if (day == null || day != ethDate.day) {
        continue;
      }
      final name = '${item['name_en'] ?? ''}'.trim();
      if (name.isEmpty) {
        continue;
      }
      return SaintSummary(
        id: 'monthly_primary_${_slug(name)}',
        name: name,
        snippet: _synaxariumSnippet(ethDate.day, fallback: 'Core monthly primary day'),
      );
    }
    return null;
  }

  List<SaintSummary> _fallbackMonthlyItems(
    Map<String, dynamic> data,
    EthDate ethDate,
  ) {
    final blocks =
        ((data['monthly_recurring_commemorations']
                as Map<String, dynamic>?)?['days'])
            as List<dynamic>? ??
        const [];
    for (final block in blocks) {
      if (block is! Map<String, dynamic>) {
        continue;
      }
      final day = int.tryParse('${block['eth_day']}');
      if (day != ethDate.day) {
        continue;
      }
      final items = block['items'] as List<dynamic>? ?? const [];
      return items.whereType<Map<String, dynamic>>().map((item) {
        final name = '${item['name_en'] ?? ''}'.trim();
        return SaintSummary(
          id: '${item['id'] ?? _slug(name)}'.trim(),
          name: name,
          snippet: _synaxariumSnippet(
            ethDate.day,
            fallback: '${item['category'] ?? 'Commemoration'}',
          ),
        );
      }).where((item) => item.id.isNotEmpty && item.name.isNotEmpty).toList();
    }
    return const [];
  }

  String _synaxariumSnippet(int ethDay, {required String fallback}) {
    final dayKey = ethDay.toString().padLeft(2, '0');
    final reading = (_readings?[dayKey] as String?)?.trim();
    if (reading == null || reading.isEmpty) {
      return fallback;
    }
    return reading;
  }

  bool _sameEthMonth(String jsonName, int month) {
    final normalized = jsonName.trim().toLowerCase();
    final monthNames = <int, List<String>>{
      1: ['meskerem', 'meskeram'],
      2: ['tikimt', 'teqemt', 'teqemt', 'teqemt'],
      3: ['hidar', 'hedar'],
      4: ['tahsas', 'tahisas'],
      5: ['tir', 'ter', 'tirr'],
      6: ['yekatit'],
      7: ['megabit'],
      8: ['miyazia', 'miazia'],
      9: ['ginbot'],
      10: ['sene', 'senie', 'seni'],
      11: ['hamle', 'hamele', 'hamlie'],
      12: ['nehase', 'nehasie', 'nehassie'],
      13: ['pagumen', 'pagume'],
    };
    return monthNames[month]?.contains(normalized) ?? false;
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
}

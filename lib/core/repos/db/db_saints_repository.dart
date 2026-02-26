import 'dart:convert';

import 'package:flutter/services.dart';

import '../../calendar/calendar_engine_models.dart';
import '../saints_repository.dart';

class DbSaintsRepository implements SaintsRepository {
  DbSaintsRepository({
    this.assetPath = 'assets/data/synaxarium_index.json',
  });

  final String assetPath;
  Map<String, dynamic>? _indexRoot;

  @override
  Future<List<SaintSummary>> fetchSaintsForDate(EthDate ethDate) async {
    final index = await _indexMap();
    for (final month in _monthCandidates(ethDate.month)) {
      final key = '$month-${ethDate.day.toString().padLeft(2, '0')}';
      final item = index[key];
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final saints = (item['saints'] as List<dynamic>? ?? const [])
          .map((value) => '$value'.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      final primary = _trimOrNull('${item['primary_saint'] ?? ''}');
      final names = saints.isEmpty
          ? (primary == null ? <String>[] : <String>[primary])
          : saints;
      return names
          .asMap()
          .entries
          .map(
            (entry) => SaintSummary(
              id: '${key}_${entry.key}',
              name: entry.value,
              snippet: 'Tap to read Synaxarium',
            ),
          )
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> _indexMap() async {
    final cached = _indexRoot;
    if (cached != null) {
      return (cached['index'] as Map<String, dynamic>? ?? const {});
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _indexRoot = decoded;
    return (decoded['index'] as Map<String, dynamic>? ?? const {});
  }

  List<String> _monthCandidates(int month) {
    const candidates = <int, List<String>>{
      1: ['Meskerem'],
      2: ['Tekemt', 'Tikimt'],
      3: ['Hedar', 'Hidar'],
      4: ['Tahisas', 'Tahsas'],
      5: ['Tir', 'Ter'],
      6: ['Yekatit'],
      7: ['Megabit'],
      8: ['Miyazia', 'Miyazya'],
      9: ['Ginbot'],
      10: ['Senne', 'Sene'],
      11: ['Hamle'],
      12: ['Nehasse', 'Nehase'],
      13: ['Pagumen', 'Pagume'],
    };
    return candidates[month] ?? const [];
  }
}

String? _trimOrNull(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
    return null;
  }
  return trimmed;
}

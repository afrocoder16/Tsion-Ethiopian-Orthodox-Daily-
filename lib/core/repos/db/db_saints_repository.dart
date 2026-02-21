import 'dart:convert';

import 'package:flutter/services.dart';

import '../../calendar/calendar_engine_models.dart';
import '../saints_repository.dart';

class DbSaintsRepository implements SaintsRepository {
  DbSaintsRepository({this.assetPath = 'assets/data/saints_index.json'});

  final String assetPath;
  Map<String, dynamic>? _index;

  @override
  Future<List<SaintSummary>> fetchSaintsForDate(EthDate ethDate) async {
    final index = await _loadIndex();
    final byEthDate = index['by_eth_date'];
    final byMmDd = index['by_mm_dd'];

    List<dynamic> rawList = const [];
    if (byEthDate is Map<String, dynamic>) {
      final list = byEthDate[ethDate.key];
      if (list is List<dynamic>) {
        rawList = list;
      }
    }

    if (rawList.isEmpty && byMmDd is Map<String, dynamic>) {
      final mmdd =
          '${ethDate.month.toString().padLeft(2, '0')}-${ethDate.day.toString().padLeft(2, '0')}';
      final list = byMmDd[mmdd];
      if (list is List<dynamic>) {
        rawList = list;
      }
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => SaintSummary(
            id: '${item['id'] ?? ''}'.trim(),
            name: '${item['name'] ?? ''}'.trim(),
            snippet: '${item['snippet'] ?? ''}'.trim(),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _loadIndex() async {
    final cached = _index;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _index = decoded;
    return decoded;
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../prayer_flow_repositories.dart';

/// Serves prayer text from the bundled content pack. English is the primary
/// body until a language preference exists; Amharic is used as fallback when
/// an entry has no English body.
class DbPrayerDetailRepository implements PrayerDetailRepository {
  DbPrayerDetailRepository({this.assetPath = 'assets/data/prayers.json'});

  final String assetPath;
  Map<String, _PrayerEntry>? _entries;

  @override
  Future<PrayerDetailState> fetchDetail(String id) async {
    final entries = await _loadEntries();
    final entry = entries[id];
    if (entry == null) {
      throw StateError('Prayer not found: $id');
    }
    final body = entry.bodyEn.isNotEmpty ? entry.bodyEn : entry.bodyAm;
    return PrayerDetailState(
      id: id,
      title: entry.title,
      stillnessTitle: entry.stillnessTitle,
      stillnessBody: entry.stillnessBody,
      body: body,
      slotId: slotIdForPrayer(id),
    );
  }

  Future<Map<String, _PrayerEntry>> _loadEntries() async {
    final cached = _entries;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final prayers = decoded['prayers'] as List<dynamic>? ?? const [];
    final entries = <String, _PrayerEntry>{};
    for (final item in prayers) {
      final map = item as Map<String, dynamic>;
      final id = '${map['id']}';
      entries[id] = _PrayerEntry(
        title: '${map['title'] ?? ''}',
        stillnessTitle: '${map['stillness_title'] ?? ''}',
        stillnessBody: '${map['stillness_body'] ?? ''}',
        bodyEn: '${map['body_en'] ?? ''}',
        bodyAm: '${map['body_am'] ?? ''}',
      );
    }
    _entries = entries;
    return entries;
  }
}

class _PrayerEntry {
  const _PrayerEntry({
    required this.title,
    required this.stillnessTitle,
    required this.stillnessBody,
    required this.bodyEn,
    required this.bodyAm,
  });

  final String title;
  final String stillnessTitle;
  final String stillnessBody;
  final String bodyEn;
  final String bodyAm;
}

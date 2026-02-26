import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../calendar/calendar_engine_models.dart';
import '../../db/app_database.dart';
import '../synaxarium_repository.dart';

class DbSynaxariumRepository implements SynaxariumRepository {
  DbSynaxariumRepository({
    required this.db,
    this.indexAssetPath = 'assets/data/synaxarium_index.json',
    this.entriesAssetPath = 'assets/data/synaxarium_entries.json',
  });

  final AppDatabase db;
  final String indexAssetPath;
  final String entriesAssetPath;

  static const String _bookmarkMetaKey = 'synaxarium_bookmarks_v1';
  static const String _snippetBookmarkMetaKey = 'synaxarium_snippet_bookmarks_v1';
  static const String _bookmarkPrefsKey = 'synaxarium_bookmarks_v1';
  static const String _snippetBookmarkPrefsKey = 'synaxarium_snippet_bookmarks_v1';

  Map<String, dynamic>? _indexRoot;
  Map<String, dynamic>? _entriesRoot;

  @override
  Future<SynaxariumIndexItem?> fetchIndexForDate(EthDate ethDate) async {
    final key = await _resolveKey(ethDate);
    if (key == null) {
      return null;
    }
    final index = await _indexMap();
    final item = index[key];
    if (item is! Map<String, dynamic>) {
      return null;
    }
    final saints = (item['saints'] as List<dynamic>? ?? const [])
        .map((value) => '$value'.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return SynaxariumIndexItem(
      key: key,
      primarySaint: _trimOrNull('${item['primary_saint'] ?? ''}'),
      saints: saints,
      needsReview: item['needs_review'] == true,
      sourceFile: '${item['source_file'] ?? ''}',
    );
  }

  @override
  Future<SynaxariumEntry?> fetchEntryForDate(EthDate ethDate) async {
    final key = await _resolveKey(ethDate);
    if (key == null) {
      return null;
    }
    return fetchEntryByKey(key);
  }

  @override
  Future<SynaxariumEntry?> fetchEntryByKey(String key) async {
    final entries = await _entriesMap();
    final item = entries[key];
    if (item is! Map<String, dynamic>) {
      return null;
    }
    final saints = (item['saints'] as List<dynamic>? ?? const [])
        .map((value) => '$value'.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return SynaxariumEntry(
      key: key,
      month: '${item['month'] ?? ''}',
      day: int.tryParse('${item['day']}') ?? (_parseEthKey(key)?.$2 ?? 1),
      primarySaint: _trimOrNull('${item['primary_saint'] ?? ''}'),
      saints: saints,
      text: '${item['text'] ?? ''}',
      sourceFile: '${item['source_file'] ?? ''}',
      needsReview: item['needs_review'] == true,
    );
  }

  @override
  Future<bool> isBookmarked(String key) async {
    final bookmarks = await _bookmarkSet();
    return bookmarks.contains(key);
  }

  @override
  Future<void> toggleBookmark(String key) async {
    final bookmarks = await _bookmarkSet();
    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }
    await _writeBookmarkSet(bookmarks);
  }

  @override
  Future<List<SynaxariumBookmarkItem>> fetchBookmarks() async {
    final bookmarks = await _bookmarkSet();
    if (bookmarks.isEmpty) {
      return const [];
    }
    final index = await _indexMap();
    final list = <SynaxariumBookmarkItem>[];
    for (final key in bookmarks) {
      final raw = index[key];
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final saints = (raw['saints'] as List<dynamic>? ?? const [])
          .map((value) => '$value'.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      list.add(
        SynaxariumBookmarkItem(
          key: key,
          primarySaint: _trimOrNull('${raw['primary_saint'] ?? ''}'),
          saints: saints,
          needsReview: raw['needs_review'] == true,
        ),
      );
    }
    list.sort((a, b) => _compareEthKeys(a.key, b.key));
    return list;
  }

  @override
  Future<void> addSnippetBookmark({
    required String entryKey,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final list = await _snippetBookmarkList();
    list.add({
      'id': '${DateTime.now().microsecondsSinceEpoch}',
      'entryKey': entryKey,
      'text': trimmed,
      'createdAtIso': DateTime.now().toUtc().toIso8601String(),
    });
    await _writeSnippetBookmarkList(list);
  }

  @override
  Future<List<SynaxariumSnippetBookmark>> fetchSnippetBookmarks({
    String? entryKey,
  }) async {
    try {
      final list = await _snippetBookmarkList();
      return list
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry('$k', v)))
        .where((item) {
          if (entryKey == null || entryKey.isEmpty) {
            return true;
          }
          return '${item['entryKey'] ?? ''}' == entryKey;
        })
        .map(
          (item) => SynaxariumSnippetBookmark(
            id: '${item['id'] ?? ''}',
            entryKey: '${item['entryKey'] ?? ''}',
            text: '${item['text'] ?? ''}',
            createdAtIso: '${item['createdAtIso'] ?? ''}',
          ),
        )
        .where((item) => item.id.isNotEmpty && item.text.trim().isNotEmpty)
        .toList()
        ..sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> removeSnippetBookmark(String id) async {
    final list = await _snippetBookmarkList();
    list.removeWhere((item) => '${item['id'] ?? ''}' == id);
    await _writeSnippetBookmarkList(list);
  }

  Future<Map<String, dynamic>> _indexMap() async {
    final cached = _indexRoot;
    if (cached != null) {
      return (cached['index'] as Map<String, dynamic>? ?? const {});
    }
    final raw = await rootBundle.loadString(indexAssetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _indexRoot = decoded;
    return (decoded['index'] as Map<String, dynamic>? ?? const {});
  }

  Future<Map<String, dynamic>> _entriesMap() async {
    final cached = _entriesRoot;
    if (cached != null) {
      return (cached['entries'] as Map<String, dynamic>? ?? const {});
    }
    final raw = await rootBundle.loadString(entriesAssetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _entriesRoot = decoded;
    return (decoded['entries'] as Map<String, dynamic>? ?? const {});
  }

  Future<Set<String>> _bookmarkSet() async {
    final raw = await _readBookmarkRaw();
    if (raw == null || raw.trim().isEmpty) {
      return <String>{};
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((value) => '$value').toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<List<dynamic>> _snippetBookmarkList() async {
    final raw = await _readSnippetBookmarkRaw();
    if (raw == null || raw.trim().isEmpty) {
      return <dynamic>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded;
    } catch (_) {
      return <dynamic>[];
    }
  }

  Future<String?> _readBookmarkRaw() async {
    try {
      final raw = await db.metaDao.readMeta(_bookmarkMetaKey);
      if (raw != null) {
        return raw;
      }
    } catch (_) {
      // Fall back to shared preferences.
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookmarkPrefsKey);
  }

  Future<String?> _readSnippetBookmarkRaw() async {
    try {
      final raw = await db.metaDao.readMeta(_snippetBookmarkMetaKey);
      if (raw != null) {
        return raw;
      }
    } catch (_) {
      // Fall back to shared preferences.
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_snippetBookmarkPrefsKey);
  }

  Future<void> _writeBookmarkSet(Set<String> bookmarks) async {
    final encoded = jsonEncode(bookmarks.toList()..sort());
    var wroteDb = false;
    try {
      await db.metaDao.upsertMeta(_bookmarkMetaKey, encoded);
      wroteDb = true;
    } catch (_) {
      wroteDb = false;
    }
    if (!wroteDb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bookmarkPrefsKey, encoded);
    }
  }

  Future<void> _writeSnippetBookmarkList(List<dynamic> items) async {
    final encoded = jsonEncode(items);
    var wroteDb = false;
    try {
      await db.metaDao.upsertMeta(_snippetBookmarkMetaKey, encoded);
      wroteDb = true;
    } catch (_) {
      wroteDb = false;
    }
    if (!wroteDb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_snippetBookmarkPrefsKey, encoded);
    }
  }

  Future<String?> _resolveKey(EthDate ethDate) async {
    final index = await _indexMap();
    for (final month in _monthCandidates(ethDate.month)) {
      final key = '$month-${ethDate.day.toString().padLeft(2, '0')}';
      if (index.containsKey(key)) {
        return key;
      }
    }
    return null;
  }

  int _compareEthKeys(String a, String b) {
    final ap = _parseEthKey(a);
    final bp = _parseEthKey(b);
    if (ap == null && bp == null) {
      return a.compareTo(b);
    }
    if (ap == null) {
      return 1;
    }
    if (bp == null) {
      return -1;
    }
    final monthCompare = ap.$1.compareTo(bp.$1);
    if (monthCompare != 0) {
      return monthCompare;
    }
    return ap.$2.compareTo(bp.$2);
  }

  (int, int)? _parseEthKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) {
      return null;
    }
    final monthOrder = _monthOrder(parts[0]);
    final day = int.tryParse(parts[1]);
    if (monthOrder == null || day == null) {
      return null;
    }
    return (monthOrder, day);
  }

  int? _monthOrder(String month) {
    const order = {
      'Meskerem': 1,
      'Tekemt': 2,
      'Tikimt': 2,
      'Hedar': 3,
      'Hidar': 3,
      'Tahisas': 4,
      'Tahsas': 4,
      'Tir': 5,
      'Ter': 5,
      'Yekatit': 6,
      'Megabit': 7,
      'Miyazia': 8,
      'Miyazya': 8,
      'Ginbot': 9,
      'Senne': 10,
      'Sene': 10,
      'Hamle': 11,
      'Nehasse': 12,
      'Nehase': 12,
      'Pagumen': 13,
      'Pagume': 13,
    };
    return order[month];
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

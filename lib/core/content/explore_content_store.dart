import 'dart:convert';

import 'package:flutter/services.dart';

/// Kinds of Explore entries; each maps to one section of the Explore screen.
enum ExploreEntryKind { study, path, community, content }

class ExploreEntry {
  const ExploreEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.body,
  });

  final String id;
  final ExploreEntryKind kind;
  final String title;
  final String subtitle;
  final String category;
  final String body;
}

/// Loads the bundled Explore content pack. The Explore screen sections and the
/// detail bodies are both generated from this file, so a tile only exists when
/// its content does.
class ExploreContentStore {
  ExploreContentStore({this.assetPath = 'assets/data/explore_content.json'});

  final String assetPath;
  List<ExploreEntry>? _entries;

  Future<List<ExploreEntry>> loadEntries() async {
    final cached = _entries;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final items = decoded['entries'] as List<dynamic>? ?? const [];
    final entries = <ExploreEntry>[];
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final kind = _kindFromName('${map['kind'] ?? ''}');
      if (kind == null) {
        continue;
      }
      entries.add(
        ExploreEntry(
          id: '${map['id'] ?? ''}',
          kind: kind,
          title: '${map['title'] ?? ''}',
          subtitle: '${map['subtitle'] ?? ''}',
          category: '${map['category'] ?? ''}',
          body: '${map['body'] ?? ''}',
        ),
      );
    }
    _entries = entries;
    return entries;
  }

  Future<List<ExploreEntry>> loadByKind(ExploreEntryKind kind) async {
    final entries = await loadEntries();
    return entries.where((entry) => entry.kind == kind).toList(growable: false);
  }

  Future<ExploreEntry?> findById(String id) async {
    final entries = await loadEntries();
    for (final entry in entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }
}

ExploreEntryKind? _kindFromName(String name) {
  for (final kind in ExploreEntryKind.values) {
    if (kind.name == name) {
      return kind;
    }
  }
  return null;
}

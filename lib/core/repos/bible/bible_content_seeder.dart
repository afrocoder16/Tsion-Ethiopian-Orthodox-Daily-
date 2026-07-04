import 'dart:convert';

import 'package:flutter/services.dart';

import '../../db/app_database.dart';
import 'bible_asset_manifest.dart';

typedef BibleAssetLoader = Future<String> Function(String path);

class BibleSeedResult {
  const BibleSeedResult({required this.didSeed, required this.verseCount});

  final bool didSeed;
  final int verseCount;
}

class BibleContentSeeder {
  BibleContentSeeder({
    required this.db,
    this.manifest = bibleAssetManifest,
    BibleAssetLoader? loadAsset,
    this.contentPackVersion = defaultContentPackVersion,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const defaultContentPackVersion = 'weahadu-v1';
  static const seedStatusKey = 'bible_seed_status';
  static const seedStatusPending = 'pending';
  static const contentPackVersionKey = 'bible_content_pack_version';

  final AppDatabase db;
  final List<BibleAssetManifestEntry> manifest;
  final BibleAssetLoader _loadAsset;
  final String contentPackVersion;

  String get completeSeedStatus => 'complete:$contentPackVersion';

  Future<BibleSeedResult> seedIfNeeded({bool force = false}) async {
    final status = await db.metaDao.readMeta(seedStatusKey);
    final existingVerseCount = await db.bibleDao.countVerses();
    if (!force && status == completeSeedStatus && existingVerseCount > 0) {
      return BibleSeedResult(didSeed: false, verseCount: existingVerseCount);
    }

    await db.metaDao.upsertMeta(seedStatusKey, seedStatusPending);
    final payload = await _buildPayload();
    await db.transaction(() async {
      await db.bibleDao.replaceBibleContent(
        books: payload.books,
        verses: payload.verses,
      );
      await db.metaDao.upsertMeta(seedStatusKey, completeSeedStatus);
      await db.metaDao.upsertMeta(contentPackVersionKey, contentPackVersion);
    });

    return BibleSeedResult(didSeed: true, verseCount: payload.verses.length);
  }

  Future<_BibleSeedPayload> _buildPayload() async {
    final books = <BibleBooksCompanion>[];
    final verses = <BibleVersesCompanion>[];

    for (var index = 0; index < manifest.length; index += 1) {
      final entry = manifest[index];
      final enData = await _loadBook(entry, 'en');
      final amData = await _loadBook(entry, 'am');
      if (enData == null && amData == null) {
        throw StateError('Bible asset missing: ${entry.id}');
      }

      final enVerses = _extractVerses(enData);
      final amVerses = _extractVerses(amData);
      final verseKeys =
          <(int, int)>{...enVerses.keys, ...amVerses.keys}.toList()
            ..sort((a, b) {
              final chapterCompare = a.$1.compareTo(b.$1);
              if (chapterCompare != 0) {
                return chapterCompare;
              }
              return a.$2.compareTo(b.$2);
            });

      final maxChapter = verseKeys.fold<int>(
        entry.chapters,
        (max, key) => key.$1 > max ? key.$1 : max,
      );
      final orderIndex = index + 1;
      books.add(
        BibleBooksCompanion.insert(
          id: entry.id,
          canonId: _fieldString(
            enData,
            'book_number',
            fallback: _fieldString(
              amData,
              'book_number',
              fallback: '$orderIndex',
            ),
          ),
          testament: _fieldString(
            enData,
            'testament',
            fallback: _fieldString(
              amData,
              'testament',
              fallback: orderIndex <= 54 ? 'old' : 'new',
            ),
          ),
          orderIndex: orderIndex,
          nameEn: _fieldString(enData, 'book_name_en', fallback: entry.en),
          nameAm: _fieldString(amData, 'book_name_am', fallback: entry.am),
          abbrevEn: _fieldString(
            enData,
            'book_short_name_en',
            fallback: entry.en,
          ),
          abbrevAm: _fieldString(
            amData,
            'book_short_name_am',
            fallback: entry.am,
          ),
          chapters: maxChapter,
        ),
      );

      for (final key in verseKeys) {
        verses.add(
          BibleVersesCompanion.insert(
            bookId: entry.id,
            chapter: key.$1,
            verse: key.$2,
            textEn: enVerses[key] ?? '',
            textAm: amVerses[key] ?? '',
          ),
        );
      }
    }

    return _BibleSeedPayload(books: books, verses: verses);
  }

  Future<Map<String, dynamic>?> _loadBook(
    BibleAssetManifestEntry entry,
    String lang,
  ) async {
    try {
      final raw = await _loadAsset('${bibleAssetPath(lang)}${entry.file}');
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Map<(int, int), String> _extractVerses(Map<String, dynamic>? data) {
    if (data == null) {
      return const {};
    }
    final chapters = data['chapters'];
    if (chapters is! List) {
      return const {};
    }
    final results = <(int, int), String>{};
    for (final chapterData in chapters) {
      if (chapterData is! Map<String, dynamic>) {
        continue;
      }
      final chapterNumber = _fieldInt(chapterData, 'chapter');
      if (chapterNumber == null) {
        continue;
      }
      final sections = chapterData['sections'];
      if (sections is! List) {
        continue;
      }
      for (final section in sections) {
        if (section is! Map<String, dynamic>) {
          continue;
        }
        final sectionVerses = section['verses'];
        if (sectionVerses is! List) {
          continue;
        }
        for (final verseData in sectionVerses) {
          if (verseData is! Map<String, dynamic>) {
            continue;
          }
          final verseNumber = _fieldInt(verseData, 'verse');
          final text = verseData['text'];
          if (verseNumber == null || text is! String) {
            continue;
          }
          results[(chapterNumber, verseNumber)] = text;
        }
      }
    }
    return results;
  }

  String _fieldString(
    Map<String, dynamic>? data,
    String key, {
    required String fallback,
  }) {
    final value = data?[key];
    if (value == null) {
      return fallback;
    }
    final text = '$value'.trim();
    return text.isEmpty ? fallback : text;
  }

  int? _fieldInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}

class _BibleSeedPayload {
  const _BibleSeedPayload({required this.books, required this.verses});

  final List<BibleBooksCompanion> books;
  final List<BibleVersesCompanion> verses;
}

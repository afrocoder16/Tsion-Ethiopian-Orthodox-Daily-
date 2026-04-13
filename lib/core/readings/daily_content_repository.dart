import 'dart:convert';

import 'package:flutter/services.dart';

import '../calendar/calendar_engine_models.dart';
import '../repos/bible/bible_asset_manifest.dart';
import 'reading_models.dart';
import 'reading_reference_parser.dart';

class DailyReadingsRepository {
  DailyReadingsRepository({
    this.assetPaths = const ['assets/data/readings/april.json'],
    ReadingReferenceParser? parser,
  }) : _parser = parser ?? ReadingReferenceParser();

  final List<String> assetPaths;
  final ReadingReferenceParser _parser;

  List<ReadingPlanMonth>? _cache;
  final Map<String, Map<String, dynamic>> _bookCache = {};

  Future<DailyReadingsResult> loadForEthDate(EthDate ethDate) async {
    final months = await _loadMonths();
    ReadingPlanDay? match;
    for (final month in months) {
      for (final row in month.rows) {
        if (row.ethMonth == ethDate.month && row.ethDay == ethDate.day) {
          match = row;
          break;
        }
      }
      if (match != null) {
        break;
      }
    }

    if (match == null) {
      return const DailyReadingsResult(
        day: null,
        sections: <ReadingSection>[],
        isLoaded: false,
      );
    }

    final sections = <ReadingSection>[
      await _buildSection(
        id: 'morning',
        title: match.morningStatus == 'festal_hiatus'
            ? 'Morning: Festal Hiatus'
            : 'Morning',
        sources: match.morning,
        note: match.morningStatus == 'festal_hiatus'
            ? 'Festal Hiatus is preserved from the printed source.'
            : null,
      ),
      await _buildSection(
        id: 'qidase',
        title: 'Qidase',
        sources: match.qidase.orderedSources,
        labels: match.qidase.orderedLabels,
      ),
      await _buildSection(
        id: 'evening',
        title: 'Evening',
        sources: match.evening,
      ),
    ];

    return DailyReadingsResult(day: match, sections: sections, isLoaded: true);
  }

  Future<List<ReadingPlanMonth>> _loadMonths() async {
    if (_cache != null) {
      return _cache!;
    }
    final result = <ReadingPlanMonth>[];
    for (final assetPath in assetPaths) {
      final raw = await rootBundle.loadString(assetPath);
      result.add(
        ReadingPlanMonth.fromJson(json.decode(raw) as Map<String, dynamic>),
      );
    }
    _cache = result;
    return result;
  }

  Future<ReadingSection> _buildSection({
    required String id,
    required String title,
    required List<String> sources,
    List<String>? labels,
    String? note,
  }) async {
    final passages = <ReadingPassage>[];
    if (sources.isEmpty && note != null) {
      passages.add(
        ReadingPassage(
          reference: const ReadingPassageReference(
            source: 'Festal Hiatus',
            book: null,
            bookId: null,
            kind: ReadingReferenceKind.raw,
            parseStatus: 'source_note',
          ),
          note: note,
        ),
      );
    }
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      final reference = _parser.parse(source);
      final resolvedText = await _resolve(reference);
      final effectiveLabel = labels != null && index < labels.length
          ? labels[index]
          : null;
      passages.add(
        ReadingPassage(
          reference: effectiveLabel == null
              ? reference
              : ReadingPassageReference(
                  source: '$effectiveLabel: ${reference.source}',
                  book: reference.book,
                  bookId: reference.bookId,
                  kind: reference.kind,
                  chapter: reference.chapter,
                  fromChapter: reference.fromChapter,
                  toChapter: reference.toChapter,
                  fromVerse: reference.fromVerse,
                  toVerse: reference.toVerse,
                  verses: reference.verses,
                  toChapterEnd: reference.toChapterEnd,
                  parseStatus: reference.parseStatus,
                  sourcePsalmNumber: reference.sourcePsalmNumber,
                  biblePsalmNumber: reference.biblePsalmNumber,
                ),
          resolvedText: resolvedText,
          note: resolvedText == null ? note ?? _noteFor(reference) : note,
        ),
      );
    }
    return ReadingSection(id: id, title: title, passages: passages);
  }

  String? _noteFor(ReadingPassageReference reference) {
    if (reference.parseStatus == 'book_unmapped') {
      return 'Book abbreviation could not be mapped to the app Bible.';
    }
    if (reference.parseStatus != 'parsed') {
      return 'Reference was preserved from source but could not be resolved with confidence.';
    }
    return null;
  }

  Future<ResolvedPassageText?> _resolve(
    ReadingPassageReference reference,
  ) async {
    if (!reference.isParsed || reference.bookId == null) {
      return null;
    }
    final book = await _loadBook(reference.bookId!);
    if (book == null) {
      return null;
    }
    final manifest = bibleAssetManifest.firstWhere(
      (item) => item.id == reference.bookId,
      orElse: () =>
          throw StateError('Missing manifest for ${reference.bookId}'),
    );
    final verses = <ResolvedPassageVerse>[];
    if (reference.kind == ReadingReferenceKind.wholeChapter) {
      verses.addAll(_chapterVerses(book, reference.chapter!));
    } else if (reference.kind == ReadingReferenceKind.chapterRange) {
      for (
        var chapter = reference.fromChapter!;
        chapter <= reference.toChapter!;
        chapter++
      ) {
        verses.addAll(_chapterVerses(book, chapter));
      }
    } else if (reference.kind == ReadingReferenceKind.verseRange) {
      final startChapter = reference.fromChapter ?? reference.chapter!;
      final endChapter = reference.toChapter ?? reference.chapter!;
      for (var chapter = startChapter; chapter <= endChapter; chapter++) {
        final chapterVerses = _chapterVerses(book, chapter);
        final isStart = chapter == startChapter;
        final isEnd = chapter == endChapter;
        verses.addAll(
          chapterVerses.where((item) {
            final lowerBound = isStart ? (reference.fromVerse ?? 1) : 1;
            final upperBound = isEnd
                ? (reference.toChapterEnd ? 9999 : (reference.toVerse ?? 9999))
                : 9999;
            return item.verse >= lowerBound && item.verse <= upperBound;
          }),
        );
      }
    } else if (reference.kind == ReadingReferenceKind.verseList) {
      final chapterVerses = _chapterVerses(book, reference.chapter!);
      verses.addAll(
        chapterVerses.where((item) => reference.verses.contains(item.verse)),
      );
    } else {
      return null;
    }
    if (verses.isEmpty) {
      return null;
    }
    return ResolvedPassageText(
      bookId: manifest.id,
      bookTitle: manifest.en,
      verses: verses,
    );
  }

  Future<Map<String, dynamic>?> _loadBook(String bookId) async {
    if (_bookCache.containsKey(bookId)) {
      return _bookCache[bookId];
    }
    final manifest = bibleAssetManifest
        .where((item) => item.id == bookId)
        .firstOrNull;
    if (manifest == null) {
      return null;
    }
    final raw = await rootBundle.loadString(
      '$bibleAssetBasePath${manifest.file}',
    );
    final data = json.decode(raw) as Map<String, dynamic>;
    _bookCache[bookId] = data;
    return data;
  }

  List<ResolvedPassageVerse> _chapterVerses(
    Map<String, dynamic> book,
    int chapter,
  ) {
    final chapters = book['chapters'] as List<dynamic>? ?? const <dynamic>[];
    Map<String, dynamic>? chapterData;
    for (final item in chapters) {
      final map = item as Map<String, dynamic>;
      if (map['chapter'] == chapter) {
        chapterData = map;
        break;
      }
    }
    if (chapterData == null) {
      return const <ResolvedPassageVerse>[];
    }
    final verses = <ResolvedPassageVerse>[];
    final sections =
        chapterData['sections'] as List<dynamic>? ?? const <dynamic>[];
    for (final section in sections) {
      for (final verse
          in section['verses'] as List<dynamic>? ?? const <dynamic>[]) {
        verses.add(
          ResolvedPassageVerse(
            chapter: chapter,
            verse: verse['verse'] as int,
            text: '${verse['text'] ?? ''}',
          ),
        );
      }
    }
    return verses;
  }
}

class DailyVerseRepository {
  DailyVerseRepository({
    this.assetPath = 'assets/data/daily_verse_entries.json',
  });

  final String assetPath;
  List<DailyVerseEntry>? _cache;

  Future<DailyVerseEntry> loadForDate(DateTime date) async {
    final entries = await _loadEntries();
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final selected = entries[(dayOfYear - 1) % entries.length];
    return _resolveEntry(selected);
  }

  Future<List<DailyVerseEntry>> _loadEntries() async {
    if (_cache != null) {
      return _cache!;
    }
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    _cache = decoded
        .map((item) => DailyVerseEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _cache!;
  }

  Future<DailyVerseEntry> _resolveEntry(DailyVerseEntry entry) async {
    if (entry.bookId == null || entry.chapter == null || entry.verse == null) {
      return entry;
    }
    final manifest = bibleAssetManifest
        .where((item) => item.id == entry.bookId)
        .firstOrNull;
    if (manifest == null) {
      return entry;
    }
    final raw = await rootBundle.loadString(
      '$bibleAssetBasePath${manifest.file}',
    );
    final data = json.decode(raw) as Map<String, dynamic>;
    final verses = _collectChapterVerses(data, entry.chapter!);
    if (verses.isEmpty) {
      return entry;
    }
    final lastVerse = entry.verseEnd ?? entry.verse!;
    final selectedVerses = verses
        .where((item) => item.verse >= entry.verse! && item.verse <= lastVerse)
        .toList(growable: false);
    if (selectedVerses.isEmpty) {
      return entry;
    }
    final reference = entry.verseEnd != null && entry.verseEnd != entry.verse
        ? '${manifest.am} ${entry.chapter}:${entry.verse}-${entry.verseEnd}'
        : '${manifest.am} ${entry.chapter}:${entry.verse}';
    final body = selectedVerses.map((item) => item.text).join(' ');
    return DailyVerseEntry(
      id: entry.id,
      title: entry.title,
      reference: reference,
      body: body,
      bookId: entry.bookId,
      chapter: entry.chapter,
      verse: entry.verse,
      verseEnd: entry.verseEnd,
    );
  }

  List<ResolvedPassageVerse> _collectChapterVerses(
    Map<String, dynamic> book,
    int chapter,
  ) {
    final chapters = book['chapters'] as List<dynamic>? ?? const <dynamic>[];
    Map<String, dynamic>? chapterData;
    for (final item in chapters) {
      final map = item as Map<String, dynamic>;
      if (map['chapter'] == chapter) {
        chapterData = map;
        break;
      }
    }
    if (chapterData == null) {
      return const <ResolvedPassageVerse>[];
    }
    final verses = <ResolvedPassageVerse>[];
    final sections =
        chapterData['sections'] as List<dynamic>? ?? const <dynamic>[];
    for (final section in sections) {
      for (final verse
          in section['verses'] as List<dynamic>? ?? const <dynamic>[]) {
        verses.add(
          ResolvedPassageVerse(
            chapter: chapter,
            verse: verse['verse'] as int,
            text: '${verse['text'] ?? ''}',
          ),
        );
      }
    }
    return verses;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

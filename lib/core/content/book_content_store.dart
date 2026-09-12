import 'dart:convert';

import 'package:flutter/services.dart';

/// Book ids that belong to the Daily Prayers collection screen rather than
/// the Orthodox Books shelf.
const String wudaseMariamBookId = 'book-wudase-mariyam';

const Set<String> dailyPrayerBookIds = {
  wudaseMariamBookId,
  'book-psalms',
  'book-sene-gologota',
  'book-seyfe-selase',
  'book-seyfe-melekot',
};

class BookContentChapter {
  const BookContentChapter({required this.label, required this.passages});

  final String label;
  final List<String> passages;
}

class BookContent {
  const BookContent({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.chapters,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final List<BookContentChapter> chapters;
}

/// Loads non-Bible book content bundled with the app.
///
/// Books are auto-discovered from the asset manifest, so dropping a new
/// `<book-id>.json` into that folder (and rebuilding) is all it takes to make
/// a book appear in the app. Book ids not present here are hidden from the
/// library lists instead of showing stub text.
class BookContentStore {
  BookContentStore({
    this.assetDir = 'assets/data/books/',
    this.supplementalAssetPaths = const ['assets/wudase_mariam.json'],
  });

  final String assetDir;
  final List<String> supplementalAssetPaths;
  Map<String, BookContent>? _books;

  Future<List<BookContent>> listBooks() async {
    final books = await _loadAll();
    final sorted = books.values.toList(growable: false)
      ..sort((a, b) => a.title.compareTo(b.title));
    return sorted;
  }

  Future<BookContent?> findById(String id) async {
    final books = await _loadAll();
    return books[id];
  }

  Future<bool> hasBook(String id) async {
    final books = await _loadAll();
    return books.containsKey(id);
  }

  Future<Map<String, BookContent>> _loadAll() async {
    final cached = _books;
    if (cached != null) {
      return cached;
    }
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final bundledAssets = manifest.listAssets();
    final paths = <String>{
      ...bundledAssets.where(
        (path) => path.startsWith(assetDir) && path.endsWith('.json'),
      ),
      ...supplementalAssetPaths.where(bundledAssets.contains),
    };
    final books = <String, BookContent>{};
    for (final path in paths) {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final book = _parseBook(decoded);
      if (book != null) {
        books[book.id] = book;
      }
    }
    _books = books;
    return books;
  }

  BookContent? _parseBook(Map<String, dynamic> map) {
    if (map['book_id'] == 'wudase_mariam') {
      return _parseWudaseMariam(map);
    }

    final id = '${map['id'] ?? ''}';
    if (id.isEmpty) {
      return null;
    }
    final chapterList = map['chapters'] as List<dynamic>? ?? const [];
    final chapters = <BookContentChapter>[];
    for (final item in chapterList) {
      final chapterMap = item as Map<String, dynamic>;
      final passages = (chapterMap['passages'] as List<dynamic>? ?? const [])
          .map((passage) => '$passage')
          .where((passage) => passage.isNotEmpty)
          .toList(growable: false);
      chapters.add(
        BookContentChapter(
          label: '${chapterMap['label'] ?? ''}',
          passages: passages,
        ),
      );
    }
    return BookContent(
      id: id,
      title: '${map['title'] ?? ''}',
      author: '${map['author'] ?? ''}',
      description: '${map['description'] ?? ''}',
      chapters: chapters,
    );
  }

  BookContent? _parseWudaseMariam(Map<String, dynamic> map) {
    final app = map['app'] as Map<String, dynamic>? ?? const {};
    final id = '${app['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      return null;
    }

    final tocMaps = (app['table_of_contents'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final tocById = <String, Map<String, dynamic>>{
      for (final item in tocMaps) '${item['section_id'] ?? ''}': item,
    };
    final tocOrder = <String, int>{
      for (var index = 0; index < tocMaps.length; index++)
        '${tocMaps[index]['section_id'] ?? ''}': index,
    };
    final sectionMaps =
        (map['sections'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .toList(growable: false)
          ..sort((a, b) {
            final aId = '${a['section_id'] ?? ''}';
            final bId = '${b['section_id'] ?? ''}';
            final aOrder =
                tocOrder[aId] ?? tocMaps.length + _intValue(a['order']);
            final bOrder =
                tocOrder[bId] ?? tocMaps.length + _intValue(b['order']);
            return aOrder.compareTo(bOrder);
          });
    final chapters = <BookContentChapter>[];
    for (final section in sectionMaps) {
      final sectionId = '${section['section_id'] ?? ''}';
      final tocEntry = tocById[sectionId];
      final passages = <String>[];
      for (final item in section['blocks'] as List<dynamic>? ?? const []) {
        final block = item as Map<String, dynamic>;
        final text = '${block['text'] ?? ''}'.trim();
        if (text.isEmpty) {
          continue;
        }
        final verseNumber = '${block['verse_num_am'] ?? ''}'.trim();
        passages.add(
          verseNumber.isNotEmpty && !text.startsWith(verseNumber)
              ? '$verseNumber  $text'
              : text,
        );
      }
      chapters.add(
        BookContentChapter(
          label: _bilingualLabel(
            tocEntry?['title_am'] ?? section['title_am'],
            tocEntry?['title_en'] ?? section['title_en'],
          ),
          passages: passages,
        ),
      );
    }

    final notice = '${app['content_notice'] ?? ''}'.trim();
    if (notice.isNotEmpty && chapters.isNotEmpty) {
      final first = chapters.first;
      chapters[0] = BookContentChapter(
        label: first.label,
        passages: [notice, ...first.passages],
      );
    }

    return BookContent(
      id: id,
      title: _textOrFallback(
        app['title'],
        _bilingualLabel(map['title_am'], map['title_en']),
      ),
      author: _textOrFallback(app['author'], map['tradition']),
      description: '${app['description'] ?? ''}'.trim(),
      chapters: chapters,
    );
  }
}

int _intValue(Object? value) =>
    value is int ? value : int.tryParse('$value') ?? 0;

String _bilingualLabel(Object? primary, Object? secondary) {
  final first = '${primary ?? ''}'.trim();
  final second = '${secondary ?? ''}'.trim();
  if (first.isEmpty) {
    return second;
  }
  if (second.isEmpty || second == first) {
    return first;
  }
  return '$first • $second';
}

String _textOrFallback(Object? value, Object? fallback) {
  final text = '${value ?? ''}'.trim();
  return text.isNotEmpty ? text : '${fallback ?? ''}'.trim();
}

import 'dart:convert';

import 'package:flutter/services.dart';

/// Book ids that belong to the Daily Prayers collection screen rather than
/// the Orthodox Books shelf.
const Set<String> dailyPrayerBookIds = {
  'book-wudase-mariyam',
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

/// Loads non-Bible book content bundled under assets/data/books/.
///
/// Books are auto-discovered from the asset manifest, so dropping a new
/// `<book-id>.json` into that folder (and rebuilding) is all it takes to make
/// a book appear in the app. Book ids not present here are hidden from the
/// library lists instead of showing stub text.
class BookContentStore {
  BookContentStore({this.assetDir = 'assets/data/books/'});

  final String assetDir;
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
    final paths = manifest
        .listAssets()
        .where((path) => path.startsWith(assetDir) && path.endsWith('.json'));
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
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../book_flow_repositories.dart';
import 'bible_asset_manifest.dart';

class BibleAssetLibraryRepository implements BibleLibraryRepository {
  @override
  Future<BibleLibraryState> fetchLibrary() async {
    final books = bibleAssetManifest
        .map(
          (entry) => BibleBook(
            id: entry.id,
            title: '${entry.en} / ${entry.am}',
            chapters: entry.chapters,
          ),
        )
        .toList(growable: false);
    return BibleLibraryState(books: books);
  }
}

class BibleAssetPassageRepository implements PassageRepository {
  @override
  Future<PassageState> fetchPassage(String bookId, int chapter) async {
    final entry = bibleAssetManifest.firstWhere(
      (item) => item.id == bookId,
      orElse: () => throw Exception('Book not found: $bookId'),
    );
    final jsonStr = await rootBundle.loadString(
      '$bibleAssetBasePath${entry.file}',
    );
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final chapters = data['chapters'] as List<dynamic>;
    final chapterData =
        chapters.firstWhere(
              (item) => (item['chapter'] as int) == chapter,
              orElse: () =>
                  throw Exception('Chapter $chapter not found in $bookId'),
            )
            as Map<String, dynamic>;
    final sections = chapterData['sections'] as List<dynamic>;
    final verses = <PassageVerse>[];
    for (final section in sections) {
      for (final verse in (section['verses'] as List<dynamic>)) {
        verses.add(
          PassageVerse(
            number: verse['verse'] as int,
            text: verse['text'] as String,
          ),
        );
      }
    }
    return PassageState(
      bookId: bookId,
      bookTitle: entry.am,
      chapter: chapter,
      verses: verses,
    );
  }
}

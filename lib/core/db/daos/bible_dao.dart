import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/bible_books.dart';
import '../tables/bible_verses.dart';

part 'bible_dao.g.dart';

class BibleSearchRow {
  const BibleSearchRow({
    required this.bookId,
    required this.bookNameEn,
    required this.bookNameAm,
    required this.chapter,
    required this.verse,
    required this.textEn,
    required this.textAm,
    required this.snippetEn,
    required this.snippetAm,
  });

  final String bookId;
  final String bookNameEn;
  final String bookNameAm;
  final int chapter;
  final int verse;
  final String textEn;
  final String textAm;
  final String snippetEn;
  final String snippetAm;
}

@DriftAccessor(tables: [BibleBooks, BibleVerses])
class BibleDao extends DatabaseAccessor<AppDatabase> with _$BibleDaoMixin {
  BibleDao(super.db);

  Future<int> countVerses() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS verse_count FROM bible_verses',
      readsFrom: {bibleVerses},
    ).getSingle();
    return row.read<int>('verse_count');
  }

  Future<List<BibleBookRow>> listBooks() {
    final query = select(bibleBooks)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]);
    return query.get();
  }

  Future<BibleBookRow?> findBook(String bookId) {
    return (select(
      bibleBooks,
    )..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();
  }

  Future<List<BibleVerseRow>> listChapter(String bookId, int chapter) {
    final query = select(bibleVerses)
      ..where((tbl) => tbl.bookId.equals(bookId) & tbl.chapter.equals(chapter))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.verse)]);
    return query.get();
  }

  Future<void> replaceBibleContent({
    required List<BibleBooksCompanion> books,
    required List<BibleVersesCompanion> verses,
  }) async {
    await customStatement('DELETE FROM bible_verses_fts');
    await delete(bibleVerses).go();
    await delete(bibleBooks).go();
    await batch((batch) {
      batch.insertAll(bibleBooks, books, mode: InsertMode.insertOrReplace);
      batch.insertAll(bibleVerses, verses, mode: InsertMode.insertOrReplace);
    });
    await rebuildFtsIndex();
  }

  Future<void> rebuildFtsIndex() {
    return customStatement('''
INSERT INTO bible_verses_fts (text_en, text_am, book_id, chapter, verse)
SELECT text_en, text_am, book_id, chapter, verse
FROM bible_verses
''');
  }

  Future<List<BibleSearchRow>> searchVerses(
    String ftsQuery, {
    int limit = 50,
  }) async {
    if (ftsQuery.trim().isEmpty) {
      return const [];
    }
    final rows = await customSelect(
      '''
SELECT
  b.id AS book_id,
  b.name_en AS book_name_en,
  b.name_am AS book_name_am,
  f.chapter AS chapter,
  f.verse AS verse,
  v.text_en AS text_en,
  v.text_am AS text_am,
  snippet(bible_verses_fts, 0, '', '', '...', 12) AS snippet_en,
  snippet(bible_verses_fts, 1, '', '', '...', 12) AS snippet_am
FROM bible_verses_fts f
JOIN bible_verses v
  ON v.book_id = f.book_id
  AND v.chapter = f.chapter
  AND v.verse = f.verse
JOIN bible_books b ON b.id = f.book_id
WHERE bible_verses_fts MATCH ?
ORDER BY b.order_index, f.chapter, f.verse
LIMIT ?
''',
      variables: [Variable<String>(ftsQuery), Variable<int>(limit)],
      readsFrom: {bibleBooks, bibleVerses},
    ).get();
    return rows
        .map(
          (row) => BibleSearchRow(
            bookId: row.read<String>('book_id'),
            bookNameEn: row.read<String>('book_name_en'),
            bookNameAm: row.read<String>('book_name_am'),
            chapter: row.read<int>('chapter'),
            verse: row.read<int>('verse'),
            textEn: row.read<String>('text_en'),
            textAm: row.read<String>('text_am'),
            snippetEn: row.read<String>('snippet_en'),
            snippetAm: row.read<String>('snippet_am'),
          ),
        )
        .toList(growable: false);
  }
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/repos/bible/bible_asset_manifest.dart';
import 'package:tsion_orthodox_daily_app/core/repos/bible/bible_content_seeder.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_book_flow_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'migration from v4 to v5 adds Bible tables, FTS, sync table, and streak bonus flag',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute('PRAGMA user_version = 4');
            raw.execute('''
CREATE TABLE meta (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL
)
''');
            raw.execute('''
CREATE TABLE streak_tasks (
  task_id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  is_required INTEGER NOT NULL
)
''');
          },
        ),
      );
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final streakColumns = await db
          .customSelect('PRAGMA table_info(streak_tasks)')
          .get();
      expect(
        streakColumns.map((row) => row.read<String>('name')),
        contains('is_bonus'),
      );

      final bibleTables = await db.customSelect('''
SELECT name FROM sqlite_master
WHERE name IN ('bible_books', 'bible_verses', 'bible_verses_fts')
''').get();
      expect(
        bibleTables.map((row) => row.read<String>('name')).toSet(),
        containsAll({'bible_books', 'bible_verses', 'bible_verses_fts'}),
      );
      final syncTables = await db.customSelect('''
SELECT name FROM sqlite_master
WHERE name = 'personal_prayers'
''').get();
      expect(
        syncTables.map((row) => row.read<String>('name')),
        contains('personal_prayers'),
      );
      expect(
        await db.metaDao.readMeta(BibleContentSeeder.seedStatusKey),
        BibleContentSeeder.seedStatusPending,
      );
    },
  );

  test('seed is idempotent and fills Bible books, verses, and FTS', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final seeder = _testSeeder(db);

    final first = await seeder.seedIfNeeded();
    final firstVerseCount = await db.bibleDao.countVerses();
    final second = await seeder.seedIfNeeded();
    final secondVerseCount = await db.bibleDao.countVerses();
    final ftsRows = await db
        .customSelect('SELECT COUNT(*) AS row_count FROM bible_verses_fts')
        .getSingle();

    expect(first.didSeed, isTrue);
    expect(first.verseCount, 3);
    expect(firstVerseCount, 3);
    expect(second.didSeed, isFalse);
    expect(secondVerseCount, firstVerseCount);
    expect(ftsRows.read<int>('row_count'), firstVerseCount);
    expect(
      await db.metaDao.readMeta(BibleContentSeeder.seedStatusKey),
      seeder.completeSeedStatus,
    );
  });

  test('default seed imports the bundled Bible content pack', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final result = await BibleContentSeeder(db: db).seedIfNeeded();
    final books = await db.bibleDao.listBooks();

    expect(result.didSeed, isTrue);
    expect(result.verseCount, greaterThan(25000));
    expect(books.length, bibleAssetManifest.length);
  });

  test('FTS finds known English and Amharic verses', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _testSeeder(db).seedIfNeeded();
    final repository = DbBibleSearchRepository(db);

    final englishCases = <(String, int)>[
      ('beginning', 1),
      ('form', 2),
      ('light', 3),
    ];
    for (final testCase in englishCases) {
      final results = await repository.search(testCase.$1, lang: 'en');
      expect(
        results.any(
          (result) => result.bookId == 'genesis' && result.verse == testCase.$2,
        ),
        isTrue,
      );
    }

    final amharicCases = <(String, int)>[('በመጀመሪያ', 1), ('ባዶ', 2), ('ብርሃን', 3)];
    for (final testCase in amharicCases) {
      final results = await repository.search(testCase.$1, lang: 'am');
      expect(
        results.any(
          (result) => result.bookId == 'genesis' && result.verse == testCase.$2,
        ),
        isTrue,
      );
    }
  });
}

BibleContentSeeder _testSeeder(AppDatabase db) {
  return BibleContentSeeder(
    db: db,
    manifest: const [
      BibleAssetManifestEntry(
        'genesis',
        '01-genesis.json',
        'Genesis',
        'ዘፍጥረት',
        1,
      ),
    ],
    loadAsset: (path) async {
      final asset = _testAssets[path];
      if (asset == null) {
        throw StateError('Missing test asset: $path');
      }
      return asset;
    },
    contentPackVersion: 'test-v1',
  );
}

final Map<String, String> _testAssets = {
  '${bibleAssetPath('en')}01-genesis.json': _bookJson(
    bookNameEn: 'Genesis',
    bookNameAm: 'ዘፍጥረት',
    shortNameEn: 'Gen',
    shortNameAm: 'ዘፍ',
    verses: const [
      'In the beginning God created the heaven and the earth.',
      'The earth was without form, and void.',
      'And God said, Let there be light, and there was light.',
    ],
  ),
  '${bibleAssetPath('am')}01-genesis.json': _bookJson(
    bookNameEn: 'Genesis',
    bookNameAm: 'ዘፍጥረት',
    shortNameEn: 'Gen',
    shortNameAm: 'ዘፍ',
    verses: const [
      'በመጀመሪያ እግዚአብሔር ሰማይን እና ምድርን ፈጠረ።',
      'ምድርም ባዶ ነበረች።',
      'እግዚአብሔርም ብርሃን ይሁን አለ።',
    ],
  ),
};

String _bookJson({
  required String bookNameEn,
  required String bookNameAm,
  required String shortNameEn,
  required String shortNameAm,
  required List<String> verses,
}) {
  return jsonEncode({
    'book_number': 1,
    'book_name_en': bookNameEn,
    'book_name_am': bookNameAm,
    'book_short_name_en': shortNameEn,
    'book_short_name_am': shortNameAm,
    'testament': 'old',
    'chapters': [
      {
        'chapter': 1,
        'sections': [
          {
            'title': '',
            'verses': [
              for (var index = 0; index < verses.length; index += 1)
                {'verse': index + 1, 'text': verses[index]},
            ],
          },
        ],
      },
    ],
  });
}

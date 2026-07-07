import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/core/content/book_content_store.dart';
import 'package:tsion_orthodox_daily_app/core/content/explore_content_store.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_book_flow_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_explore_detail_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_prayer_detail_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_synaxarium_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/prayer_flow_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('prayers content pack', () {
    const prayerIds = [
      'prayer-morning',
      'prayer-midday',
      'prayer-afternoon',
      'prayer-night',
      'trisagion-prayers',
      'psalm-50',
      'prayer-of-st-ephrem',
    ];

    test('serves real text for every prayer slot', () async {
      final repo = DbPrayerDetailRepository();
      for (final id in prayerIds) {
        final detail = await repo.fetchDetail(id);
        expect(detail.title, isNotEmpty, reason: '$id title');
        expect(
          detail.body.length,
          greaterThan(100),
          reason: '$id body should be real prayer text',
        );
        expect(
          detail.body.toLowerCase(),
          isNot(contains('placeholder')),
          reason: '$id body must not be placeholder text',
        );
        expect(detail.slotId, slotIdForPrayer(id));
      }
    });

    test('throws for unknown prayer ids', () {
      final repo = DbPrayerDetailRepository();
      expect(repo.fetchDetail('prayer-unknown'), throwsStateError);
    });
  });

  group('explore content pack', () {
    test('store loads seeded entries and filters by kind', () async {
      final store = ExploreContentStore();
      final entries = await store.loadEntries();
      expect(entries, isNotEmpty);
      final content = await store.loadByKind(ExploreEntryKind.content);
      expect(content.map((entry) => entry.id), contains('content-learning-hours'));
      for (final entry in content) {
        expect(entry.body.length, greaterThan(200), reason: '${entry.id} body');
        expect(entry.category, isNotEmpty);
      }
    });

    test('detail repository serves entry bodies and rejects unknown ids', () async {
      final repo = DbExploreDetailRepository(ExploreContentStore());
      final detail = await repo.fetchDetail('content-gospel-readings');
      expect(detail.title, 'The Gospel Readings');
      expect(detail.body.toLowerCase(), isNot(contains('placeholder')));
      expect(repo.fetchDetail('content-unknown'), throwsStateError);
    });
  });

  group('book content pack', () {
    test('store discovers bundled books from the asset manifest', () async {
      final store = BookContentStore();
      final books = await store.listBooks();
      expect(books.map((book) => book.id), contains('book-psalms'));
      final psalms = await store.findById('book-psalms');
      expect(psalms, isNotNull);
      expect(psalms!.chapters.length, 7);
      for (final chapter in psalms.chapters) {
        expect(chapter.label, isNotEmpty);
        expect(chapter.passages, isNotEmpty);
      }
    });

    test('reader serves book content and records reading progress', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DbReaderRepository(db, BookContentStore());

      final reader = await repo.fetchReader('book-psalms');
      expect(reader.bookTitle, 'Psalms');
      expect(reader.content.length, greaterThan(20));
      expect(
        reader.content.join(' ').toLowerCase(),
        isNot(contains('placeholder')),
      );

      final progress = await db.readingProgressDao.getReadingProgress(
        'book-psalms',
      );
      expect(progress, isNotNull);

      expect(repo.fetchReader('book-unknown'), throwsStateError);
    });
  });

  group('Amharic synaxarium bundle', () {
    test('entry for Meskerem 1 carries the Amharic edition', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DbSynaxariumRepository(db: db);

      final entry = await repo.fetchEntryByKey('Meskerem-01');
      expect(entry, isNotNull);
      expect(entry!.text, isNotEmpty);
      expect(entry.textAm, isNotNull);
      // Meskerem 1 opens the Amharic Synaxarium with the New Year heading.
      expect(entry.textAm, contains('ርዕሰ ዓውደ ዓመት'));
    });
  });
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tsion_orthodox_daily_app/app/route_paths.dart';
import 'package:tsion_orthodox_daily_app/core/content/book_content_store.dart';
import 'package:tsion_orthodox_daily_app/core/content/explore_content_store.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/providers/book_flow_providers.dart';
import 'package:tsion_orthodox_daily_app/core/repos/book_flow_repositories.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_book_flow_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_explore_detail_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_prayer_detail_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/db/db_synaxarium_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/prayer_flow_repositories.dart';
import 'package:tsion_orthodox_daily_app/features/bible/presentation/book_detail_screen.dart';
import 'package:tsion_orthodox_daily_app/features/prayers/presentation/daily_prayer_screen.dart';

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
      expect(
        content.map((entry) => entry.id),
        contains('content-learning-hours'),
      );
      for (final entry in content) {
        expect(entry.body.length, greaterThan(200), reason: '${entry.id} body');
        expect(entry.category, isNotEmpty);
      }
    });

    test(
      'detail repository serves entry bodies and rejects unknown ids',
      () async {
        final repo = DbExploreDetailRepository(ExploreContentStore());
        final detail = await repo.fetchDetail('content-gospel-readings');
        expect(detail.title, 'The Gospel Readings');
        expect(detail.body.toLowerCase(), isNot(contains('placeholder')));
        expect(repo.fetchDetail('content-unknown'), throwsStateError);
      },
    );
  });

  group('book content pack', () {
    test('store discovers bundled books from the asset manifest', () async {
      final store = BookContentStore();
      final books = await store.listBooks();
      expect(books.map((book) => book.id), contains('book-psalms'));
      expect(books.map((book) => book.id), contains(wudaseMariamBookId));
      final psalms = await store.findById('book-psalms');
      expect(psalms, isNotNull);
      expect(psalms!.chapters.length, 7);
      for (final chapter in psalms.chapters) {
        expect(chapter.label, isNotEmpty);
        expect(chapter.passages, isNotEmpty);
      }
    });

    test('Wudase Mariam preserves every titled source section', () async {
      final store = BookContentStore();
      final wudase = await store.findById(wudaseMariamBookId);
      expect(wudase, isNotNull);
      expect(wudase!.title, contains('ውዳሴ ማርያም'));
      expect(wudase.chapters, hasLength(10));

      final raw = await rootBundle.loadString('assets/wudase_mariam.json');
      final source = jsonDecode(raw) as Map<String, dynamic>;
      final sections = (source['sections'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final sourceTexts = sections
          .expand((section) => section['blocks'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((block) => '${block['text'] ?? ''}'.trim())
          .where((text) => text.isNotEmpty)
          .toList(growable: false);
      final rendered = wudase.chapters
          .expand((chapter) => chapter.passages)
          .join('\n');

      expect(sourceTexts, hasLength(226));
      for (final text in sourceTexts) {
        expect(rendered, contains(text));
      }
      expect(rendered, contains('Draft transcription'));
      expect(
        wudase.chapters.map((chapter) => chapter.label.split(' • ').last),
        orderedEquals([
          'General Daily Prayer',
          'Monday - Wudase Mariam',
          'Tuesday - Wudase Mariam',
          'Wednesday - Wudase Mariam',
          'Thursday - Wudase Mariam',
          'Friday - Wudase Mariam',
          'Saturday - Wudase Mariam',
          'Sunday - Wudase Mariam',
          'Anqetse Birhan',
          'Prayer of Conscience',
        ]),
      );
    });

    testWidgets('Daily Prayer screen surfaces Wudase Mariam', (tester) async {
      const book = BookContent(
        id: wudaseMariamBookId,
        title: 'ውዳሴ ማርያም • Praise of Mary',
        author: 'Ethiopian Orthodox Tewahedo tradition',
        description: 'Seven weekday praises',
        chapters: [],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyPrayerBooksProvider.overrideWith((ref) async => [book]),
          ],
          child: const MaterialApp(home: DailyPrayerScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('ውዳሴ ማርያም'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
    });

    testWidgets('table of contents opens the selected prayer section', (
      tester,
    ) async {
      const bookId = 'book-test';
      const detail = BookDetailState(
        id: bookId,
        title: 'Wudase Mariam',
        author: 'Ethiopian Orthodox Tewahedo tradition',
        description: 'Daily prayers',
        toc: [
          'General Daily Prayer',
          'Monday - Wudase Mariam',
          'Tuesday - Wudase Mariam',
        ],
        isDownloaded: true,
        resumeLabel: 'Start reading',
      );
      final router = GoRouter(
        initialLocation: RoutePaths.bookDetailPath(bookId),
        routes: [
          GoRoute(
            path: RoutePaths.bookDetail,
            builder: (context, state) => const BookDetailScreen(bookId: bookId),
          ),
          GoRoute(
            path: RoutePaths.bookReader,
            builder: (context, state) => Scaffold(
              body: Text(state.uri.queryParameters['section'] ?? 'all'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookDetailProvider(bookId).overrideWith((ref) async => detail),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final monday = find.text('Monday - Wudase Mariam');
      await tester.ensureVisible(monday);
      await tester.tap(monday);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Monday - Wudase Mariam'), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.bookDetailPath(bookId),
      );
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

      final monday = await repo.fetchReader(
        wudaseMariamBookId,
        sectionIndex: 1,
      );
      expect(monday.chapterLabel, contains('Monday - Wudase Mariam'));
      expect(monday.content.first, monday.chapterLabel);
      expect(
        monday.content.join('\n'),
        isNot(contains('Tuesday - Wudase Mariam')),
      );

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

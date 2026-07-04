import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../actions/user_actions.dart';
import '../db/app_database.dart';
import '../db/database_executor.dart';
import '../calendar/calendar_engine.dart';
import '../readings/daily_content_repository.dart';
import '../repos/db/db_books_repository.dart';
import '../repos/db/db_calendar_repository.dart';
import '../repos/db/db_saints_repository.dart';
import '../repos/db/db_explore_repository.dart';
import '../repos/db/db_prayers_repository.dart';
import '../repos/db/db_today_repository.dart';
import '../repos/repos.dart';

final useDbReposProvider = StateProvider<bool>((ref) => true);

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openExecutor());
  ref.onDispose(db.close);
  return db;
});

final calendarEngineProvider = Provider<CalendarEngine>(
  (ref) => CalendarEngine(),
);

final dailyReadingsRepositoryProvider = Provider<DailyReadingsRepository>(
  (ref) => DailyReadingsRepository(),
);

final dailyVerseRepositoryProvider = Provider<DailyVerseRepository>(
  (ref) => DailyVerseRepository(
    calendarEngine: ref.watch(calendarEngineProvider),
    dailyReadingsRepository: ref.watch(dailyReadingsRepositoryProvider),
  ),
);

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return FakeTodayRepository();
  }
  return DbTodayRepository(
    ref.watch(dbProvider),
    dailyVerseRepository: ref.watch(dailyVerseRepositoryProvider),
  );
});

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return FakeBooksRepository();
  }
  return DbBooksRepository(ref.watch(dbProvider));
});

final prayersRepositoryProvider = Provider<PrayersRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return FakePrayersRepository();
  }
  return DbPrayersRepository(ref.watch(dbProvider));
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return FakeCalendarRepository();
  }
  return DbCalendarRepository(
    db: ref.watch(dbProvider),
    engine: ref.watch(calendarEngineProvider),
    saintsRepository: DbSaintsRepository(),
    dailyReadingsRepository: ref.watch(dailyReadingsRepositoryProvider),
  );
});

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return FakeExploreRepository();
  }
  return DbExploreRepository(ref.watch(dbProvider));
});

// Saved items stream providers
final savedItemsStreamProvider = StreamProvider<List<SavedItem>>((ref) {
  return ref.read(dbProvider).savedItemsDao.watchSavedItems();
});

final verseBookmarksProvider = StreamProvider<List<SavedItem>>((ref) {
  return ref.read(dbProvider).savedItemsDao.watchByKind(kKindVerseBookmark);
});

final verseLikesProvider = StreamProvider<List<SavedItem>>((ref) {
  return ref.read(dbProvider).savedItemsDao.watchByKind(kKindVerseLike);
});

// Bible font size preference (in-memory; survives hot reload, resets on app restart)
final bibleFontSizeProvider = StateProvider<double>((ref) => 14.0);

// Reading progress per book
final readingProgressProvider =
    FutureProvider.family<ReadingProgressData?, String>((ref, bookId) {
      return ref.read(dbProvider).readingProgressDao.getReadingProgress(bookId);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_executor.dart';
import '../repos/db/db_books_repository.dart';
import '../repos/db/db_explore_repository.dart';
import '../repos/db/db_prayers_repository.dart';
import '../repos/db/db_today_repository.dart';
import '../repos/repos.dart';

final useDbReposProvider = StateProvider<bool>((ref) => true);

final dbProvider = Provider<AppDatabase>(
  (ref) {
    final db = AppDatabase(openExecutor());
    ref.onDispose(db.close);
    return db;
  },
);

final todayRepositoryProvider = Provider<TodayRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (!useDb) {
      return FakeTodayRepository();
    }
    return DbTodayRepository(ref.watch(dbProvider));
  },
);

final booksRepositoryProvider = Provider<BooksRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (!useDb) {
      return FakeBooksRepository();
    }
    return DbBooksRepository(ref.watch(dbProvider));
  },
);

final prayersRepositoryProvider = Provider<PrayersRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (!useDb) {
      return FakePrayersRepository();
    }
    return DbPrayersRepository(ref.watch(dbProvider));
  },
);

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => FakeCalendarRepository(),
);

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (!useDb) {
      return FakeExploreRepository();
    }
    return DbExploreRepository(ref.watch(dbProvider));
  },
);

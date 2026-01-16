import 'package:drift/drift.dart';

import 'daos/meta_dao.dart';
import 'daos/prayer_dao.dart';
import 'daos/reading_progress_dao.dart';
import 'daos/saved_items_dao.dart';
import 'daos/streak_dao.dart';
import 'tables/meta.dart';
import 'tables/prayer_completions.dart';
import 'tables/prayer_schedule.dart';
import 'tables/reading_progress.dart';
import 'tables/saved_items.dart';
import 'tables/streak_events.dart';
import 'tables/streak_tasks.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Meta,
    SavedItems,
    ReadingProgress,
    StreakTasks,
    StreakEvents,
    PrayerSchedule,
    PrayerCompletions,
  ],
  daos: [
    MetaDao,
    SavedItemsDao,
    ReadingProgressDao,
    StreakDao,
    PrayerDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement('''
CREATE TABLE IF NOT EXISTS streak_tasks (
  task_id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  is_required INTEGER NOT NULL
)
''');
        await customStatement('''
CREATE TABLE IF NOT EXISTS streak_events (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  date_ymd TEXT NOT NULL,
  task_id TEXT NOT NULL,
  completed_at_iso TEXT NOT NULL,
  UNIQUE(date_ymd, task_id)
)
''');
      }
    },
  );
}

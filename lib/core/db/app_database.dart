import 'package:drift/drift.dart';

import 'daos/bible_dao.dart';
import 'daos/meta_dao.dart';
import 'daos/personal_prayers_dao.dart';
import 'daos/prayer_dao.dart';
import 'daos/reading_progress_dao.dart';
import 'daos/saved_items_dao.dart';
import 'daos/streak_dao.dart';
import 'tables/bible_books.dart';
import 'tables/bible_verses.dart';
import 'tables/meta.dart';
import 'tables/personal_prayers.dart';
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
    PersonalPrayers,
    BibleBooks,
    BibleVerses,
  ],
  daos: [
    MetaDao,
    SavedItemsDao,
    ReadingProgressDao,
    StreakDao,
    PrayerDao,
    PersonalPrayersDao,
    BibleDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createBibleFts();
      await _markBibleSeedPending();
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
      if (from < 3) {
        await customStatement('ALTER TABLE saved_items ADD COLUMN body TEXT;');
      }
      if (from < 4) {
        await customStatement('''
CREATE TABLE IF NOT EXISTS reading_progress (
  book_id TEXT NOT NULL PRIMARY KEY,
  last_location TEXT NOT NULL,
  progress_text TEXT NOT NULL,
  updated_at_iso TEXT NOT NULL
)
''');
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE streak_tasks ADD COLUMN is_bonus INTEGER NOT NULL DEFAULT 0;',
        );
        await m.createTable(bibleBooks);
        await m.createTable(bibleVerses);
        await m.createTable(personalPrayers);
        await _createBibleFts();
        await _markBibleSeedPending();
      }
    },
  );

  Future<void> _createBibleFts() {
    return customStatement('''
CREATE VIRTUAL TABLE IF NOT EXISTS bible_verses_fts USING fts5(
  text_en,
  text_am,
  book_id UNINDEXED,
  chapter UNINDEXED,
  verse UNINDEXED
)
''');
  }

  Future<void> _markBibleSeedPending() {
    return customStatement('''
INSERT OR REPLACE INTO meta (key, value)
VALUES ('bible_seed_status', 'pending')
''');
  }
}

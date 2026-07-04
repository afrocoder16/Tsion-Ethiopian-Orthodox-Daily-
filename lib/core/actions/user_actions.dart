import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../sync/user_data_sync.dart';

const kKindVerseBookmark = 'verse-bookmark';
const kKindVerseLike = 'verse-like';
const kKindChapterBookmark = 'chapter-bookmark';

Future<void> toggleSave({
  required AppDatabase db,
  required String id,
  required String title,
  required String kind,
  required String createdAtIso,
  String? body,
  UserDataSyncService? sync,
}) async {
  final existing = await (db.select(
    db.savedItems,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  if (existing == null) {
    await db.savedItemsDao.addSavedItem(
      id: id,
      title: title,
      kind: kind,
      createdAtIso: createdAtIso,
      body: body,
    );
    await sync?.mirrorBookmarkSaved(
      id: id,
      title: title,
      kind: kind,
      createdAtIso: createdAtIso,
      body: body,
    );
  } else {
    await db.savedItemsDao.removeSavedItem(id);
    await sync?.mirrorBookmarkDeleted(id);
  }
}

Future<void> setReadingProgress({
  required AppDatabase db,
  required String bookId,
  required String lastLocation,
  required String progressText,
  required String updatedAtIso,
}) {
  return db.readingProgressDao.upsertReadingProgress(
    bookId: bookId,
    lastLocation: lastLocation,
    progressText: progressText,
    updatedAtIso: updatedAtIso,
  );
}

Future<void> completeStreakTask({
  required AppDatabase db,
  required String dateYmd,
  required String taskId,
  required String completedAtIso,
  UserDataSyncService? sync,
}) async {
  await db.streakDao.completeTask(
    dateYmd: dateYmd,
    taskId: taskId,
    completedAtIso: completedAtIso,
  );
  await sync?.mirrorStreakCompleted(
    dateYmd: dateYmd,
    taskId: taskId,
    completedAtIso: completedAtIso,
  );
}

Future<void> toggleStreakTask({
  required AppDatabase db,
  required String dateYmd,
  required String taskId,
  required String completedAtIso,
  UserDataSyncService? sync,
}) async {
  final existing =
      await (db.select(db.streakEvents)..where(
            (tbl) => tbl.dateYmd.equals(dateYmd) & tbl.taskId.equals(taskId),
          ))
          .getSingleOrNull();
  if (existing == null) {
    await db.streakDao.completeTask(
      dateYmd: dateYmd,
      taskId: taskId,
      completedAtIso: completedAtIso,
    );
    await sync?.mirrorStreakCompleted(
      dateYmd: dateYmd,
      taskId: taskId,
      completedAtIso: completedAtIso,
    );
  } else {
    await db.streakDao.removeTaskCompletion(dateYmd: dateYmd, taskId: taskId);
    await sync?.mirrorStreakRemoved(dateYmd: dateYmd, taskId: taskId);
  }
}

Future<void> completePrayer({
  required AppDatabase db,
  required String dateYmd,
  required int slotId,
  required String completedAtIso,
  UserDataSyncService? sync,
}) async {
  await db.prayerDao.addPrayerCompletion(
    dateYmd: dateYmd,
    slotId: slotId,
    completedAtIso: completedAtIso,
  );
  await sync?.mirrorPrayerCompletion(
    dateYmd: dateYmd,
    slotId: slotId,
    completedAtIso: completedAtIso,
  );
}

Future<void> savePersonalPrayer({
  required AppDatabase db,
  required String id,
  required String name,
  required String intention,
  required String createdAtIso,
  required String updatedAtIso,
  String? dueAtIso,
  UserDataSyncService? sync,
}) async {
  await db.personalPrayersDao.upsertPersonalPrayer(
    id: id,
    name: name,
    intention: intention,
    createdAtIso: createdAtIso,
    updatedAtIso: updatedAtIso,
    dueAtIso: dueAtIso,
  );
  await sync?.mirrorPersonalPrayer(
    id: id,
    name: name,
    intention: intention,
    createdAtIso: createdAtIso,
    updatedAtIso: updatedAtIso,
    dueAtIso: dueAtIso,
  );
}

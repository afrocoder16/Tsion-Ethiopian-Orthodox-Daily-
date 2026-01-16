import 'package:drift/drift.dart';

import '../db/app_database.dart';

Future<void> toggleSave({
  required AppDatabase db,
  required String id,
  required String title,
  required String kind,
  required String createdAtIso,
}) async {
  final existing = await (db.select(db.savedItems)
        ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();
  if (existing == null) {
    await db.savedItemsDao.addSavedItem(
      id: id,
      title: title,
      kind: kind,
      createdAtIso: createdAtIso,
    );
  } else {
    await db.savedItemsDao.removeSavedItem(id);
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
}) {
  return db.streakDao.completeTask(
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
}) async {
  final existing = await (db.select(db.streakEvents)
        ..where(
          (tbl) =>
              tbl.dateYmd.equals(dateYmd) & tbl.taskId.equals(taskId),
        ))
      .getSingleOrNull();
  if (existing == null) {
    await db.streakDao.completeTask(
      dateYmd: dateYmd,
      taskId: taskId,
      completedAtIso: completedAtIso,
    );
  } else {
    await db.streakDao.removeTaskCompletion(
      dateYmd: dateYmd,
      taskId: taskId,
    );
  }
}

Future<void> completePrayer({
  required AppDatabase db,
  required String dateYmd,
  required int slotId,
  required String completedAtIso,
}) {
  return db.prayerDao.addPrayerCompletion(
    dateYmd: dateYmd,
    slotId: slotId,
    completedAtIso: completedAtIso,
  );
}

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/streak_events.dart';
import '../tables/streak_tasks.dart';

part 'streak_dao.g.dart';

class StreakTaskStatus {
  const StreakTaskStatus({
    required this.task,
    required this.completed,
  });

  final StreakTask task;
  final bool completed;
}

@DriftAccessor(tables: [StreakTasks, StreakEvents])
class StreakDao extends DatabaseAccessor<AppDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  Future<void> upsertTask({
    required String taskId,
    required String title,
    required bool isRequired,
  }) {
    return into(streakTasks).insertOnConflictUpdate(
      StreakTasksCompanion(
        taskId: Value(taskId),
        title: Value(title),
        isRequired: Value(isRequired),
      ),
    );
  }

  Future<void> completeTask({
    required String dateYmd,
    required String taskId,
    required String completedAtIso,
  }) {
    return into(streakEvents).insertOnConflictUpdate(
      StreakEventsCompanion(
        dateYmd: Value(dateYmd),
        taskId: Value(taskId),
        completedAtIso: Value(completedAtIso),
      ),
    );
  }

  Future<void> removeTaskCompletion({
    required String dateYmd,
    required String taskId,
  }) {
    return (delete(streakEvents)
          ..where(
            (tbl) =>
                tbl.dateYmd.equals(dateYmd) & tbl.taskId.equals(taskId),
          ))
        .go();
  }

  Future<List<StreakTaskStatus>> getStreakStatusForDate(String dateYmd) async {
    final query = select(streakTasks).join([
      leftOuterJoin(
        streakEvents,
        streakEvents.taskId.equalsExp(streakTasks.taskId) &
            streakEvents.dateYmd.equals(dateYmd),
      ),
    ]);

    final rows = await query.get();
    return rows.map((row) {
      final task = row.readTable(streakTasks);
      final event = row.readTableOrNull(streakEvents);
      return StreakTaskStatus(
        task: task,
        completed: event != null,
      );
    }).toList();
  }
}

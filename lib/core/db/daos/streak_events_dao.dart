import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/streak_events.dart';
import '../tables/streak_tasks.dart';

part 'streak_events_dao.g.dart';

class StreakEventStatus {
  const StreakEventStatus({
    required this.task,
    required this.completed,
  });

  final StreakTask task;
  final bool completed;
}

@DriftAccessor(tables: [StreakTasks, StreakEvents])
class StreakEventsDao extends DatabaseAccessor<AppDatabase>
    with _$StreakEventsDaoMixin {
  StreakEventsDao(super.db);

  Future<List<StreakEventStatus>> getStreakStatusForDate(String dateYmd) async {
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
      return StreakEventStatus(
        task: task,
        completed: event != null,
      );
    }).toList();
  }
}

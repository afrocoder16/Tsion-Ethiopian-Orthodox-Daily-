import '../../db/app_database.dart';
import '../../db/daos/streak_dao.dart';
import '../../streak/streak_tasks.dart';
import '../streak_repositories.dart';

class DbStreakRepository implements StreakRepository {
  DbStreakRepository(this.db);

  final AppDatabase db;

  @override
  Future<StreakScreenState> fetchStreakScreen() async {
    try {
      return await _fetchStreakScreenInternal();
    } catch (_) {
      await _ensureStreakTablesExist();
      try {
        return await _fetchStreakScreenInternal();
      } catch (_) {
        final now = DateTime.now();
        final tasks = buildStreakTasks();
        return _buildFallbackState(now, tasks);
      }
    }
  }

  Future<StreakScreenState> _fetchStreakScreenInternal() async {
    final tasks = buildStreakTasks();
    final streakDao = StreakDao(db);
    for (final task in tasks) {
      await streakDao.upsertTask(
        taskId: task.id,
        title: task.title,
        isRequired: true,
      );
    }

    final today = DateTime.now();
    final todayKey = _formatYmd(today);
    final todayStatuses = await streakDao.getStreakStatusForDate(todayKey);
    final todayCompleted = todayStatuses.where((item) => item.completed).length;

    final statusByTaskId = {
      for (final status in todayStatuses) status.task.taskId: status.completed,
    };

    final practiceItems = tasks
        .map(
          (task) => StreakPracticeItem(
            id: task.id,
            title: task.title,
            iconKey: task.iconKey,
            isDone: statusByTaskId[task.id] ?? false,
            routePath: task.routePath,
          ),
        )
        .toList();

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = <StreakWeekDay>[];
    var weekCompletedCount = 0;
    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = _formatYmd(date);
      final statuses = await streakDao.getStreakStatusForDate(dateKey);
      final completedCount = statuses.where((item) => item.completed).length;
      final isComplete = statuses.isNotEmpty && completedCount == tasks.length;
      if (isComplete) {
        weekCompletedCount++;
      }
      weekDays.add(
        StreakWeekDay(
          label: _weekdayLabel(date),
          isComplete: isComplete,
          isToday: _isSameDay(date, today),
        ),
      );
    }

    final streakDays = await _calculateStreakDays(streakDao, tasks.length);
    final subtext = _buildSubtext(
      completed: todayCompleted,
      total: tasks.length,
    );

    return StreakScreenState(
      dayLabel: _weekdayLong(today),
      dateLine: _formatLongDate(today),
      completedCount: todayCompleted,
      totalCount: tasks.length,
      streakDays: streakDays,
      subtext: subtext,
      weekTitle: 'This Week Rhythm',
      weekCompletedCount: weekCompletedCount,
      weekDays: weekDays,
      socialCard: const StreakSocialCard(
        title: 'Daily Practice Circle',
        subtitle: 'Build a steady rhythm with prayer, verse, and readings',
      ),
      practiceTitle: 'Daily Rhythm',
      practiceItems: practiceItems,
    );
  }

  Future<void> _ensureStreakTablesExist() async {
    await db.customStatement('''
CREATE TABLE IF NOT EXISTS streak_tasks (
  task_id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  is_required INTEGER NOT NULL
)
''');
    await db.customStatement('''
CREATE TABLE IF NOT EXISTS streak_events (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  date_ymd TEXT NOT NULL,
  task_id TEXT NOT NULL,
  completed_at_iso TEXT NOT NULL,
  UNIQUE(date_ymd, task_id)
)
''');
  }

  StreakScreenState _buildFallbackState(
    DateTime today,
    List<StreakTaskDefinition> tasks,
  ) {
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List<StreakWeekDay>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return StreakWeekDay(
        label: _weekdayLabel(date),
        isComplete: false,
        isToday: _isSameDay(date, today),
      );
    });
    final practiceItems = tasks
        .map(
          (task) => StreakPracticeItem(
            id: task.id,
            title: task.title,
            iconKey: task.iconKey,
            isDone: false,
            routePath: task.routePath,
          ),
        )
        .toList();
    return StreakScreenState(
      dayLabel: _weekdayLong(today),
      dateLine: _formatLongDate(today),
      completedCount: 0,
      totalCount: tasks.length,
      streakDays: 0,
      subtext: 'Begin your daily rhythm',
      weekTitle: 'This Week Rhythm',
      weekCompletedCount: 0,
      weekDays: weekDays,
      socialCard: const StreakSocialCard(
        title: 'Daily Practice Circle',
        subtitle: 'Build a steady rhythm with prayer, verse, and readings',
      ),
      practiceTitle: 'Daily Rhythm',
      practiceItems: practiceItems,
    );
  }

  Future<int> _calculateStreakDays(StreakDao streakDao, int totalTasks) async {
    var streakDays = 0;
    var cursor = DateTime.now();
    for (var i = 0; i < 30; i++) {
      final dateKey = _formatYmd(cursor);
      final statuses = await streakDao.getStreakStatusForDate(dateKey);
      final completedCount = statuses.where((item) => item.completed).length;
      if (statuses.isNotEmpty && completedCount == totalTasks) {
        streakDays++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streakDays;
  }
}

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatLongDate(DateTime dateTime) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final month = months[dateTime.month - 1];
  return '$month ${dateTime.day}, ${dateTime.year}';
}

String _weekdayLabel(DateTime dateTime) {
  const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return labels[dateTime.weekday - 1];
}

String _weekdayLong(DateTime dateTime) {
  const labels = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  return labels[dateTime.weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _buildSubtext({required int completed, required int total}) {
  final remaining = total - completed;
  if (remaining <= 0) {
    return 'Daily rhythm complete';
  }
  if (remaining == 1) {
    return '1 more to complete today';
  }
  if (remaining == 2) {
    return '2 more to complete today';
  }
  return 'Begin your daily rhythm';
}

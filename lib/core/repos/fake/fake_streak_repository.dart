import '../../streak/streak_tasks.dart';
import '../streak_repositories.dart';

class FakeStreakRepository implements StreakRepository {
  @override
  Future<StreakScreenState> fetchStreakScreen() {
    final tasks = buildStreakTasks();
    final dayLabel = 'MONDAY';
    final dateLine = 'January 12, 2026';
    final practiceItems = tasks
        .map(
          (task) => StreakPracticeItem(
            id: task.id,
            title: task.title,
            iconKey: task.iconKey,
            isDone: task.id == streakTaskPrayer,
            routePath: task.routePath,
          ),
        )
        .toList();

    final weekDays = const [
      StreakWeekDay(label: 'MON', isComplete: true, isToday: true),
      StreakWeekDay(label: 'TUE', isComplete: false, isToday: false),
      StreakWeekDay(label: 'WED', isComplete: false, isToday: false),
      StreakWeekDay(label: 'THU', isComplete: false, isToday: false),
      StreakWeekDay(label: 'FRI', isComplete: false, isToday: false),
      StreakWeekDay(label: 'SAT', isComplete: false, isToday: false),
      StreakWeekDay(label: 'SUN', isComplete: false, isToday: false),
    ];

    return Future.value(
      StreakScreenState(
        dayLabel: dayLabel,
        dateLine: dateLine,
        completedCount: 1,
        totalCount: tasks.length,
        streakDays: 2,
        subtext: 'Keep the rhythm today',
        weekTitle: 'This Week Progress',
        weekCompletedCount: 1,
        weekDays: weekDays,
        socialCard: const StreakSocialCard(
          title: 'Daily Practice Circle',
          subtitle: 'Create or join a Daily Practice Circle',
        ),
        practiceTitle: 'Daily Practice',
        practiceItems: practiceItems,
      ),
    );
  }
}

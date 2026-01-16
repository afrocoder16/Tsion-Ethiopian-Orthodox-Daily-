class StreakWeekDay {
  const StreakWeekDay({
    required this.label,
    required this.isComplete,
    required this.isToday,
  });

  final String label;
  final bool isComplete;
  final bool isToday;
}

class StreakPracticeItem {
  const StreakPracticeItem({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.isDone,
    required this.routePath,
  });

  final String id;
  final String title;
  final String iconKey;
  final bool isDone;
  final String? routePath;
}

class StreakSocialCard {
  const StreakSocialCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class StreakScreenState {
  const StreakScreenState({
    required this.dayLabel,
    required this.dateLine,
    required this.completedCount,
    required this.totalCount,
    required this.streakDays,
    required this.subtext,
    required this.weekTitle,
    required this.weekCompletedCount,
    required this.weekDays,
    required this.socialCard,
    required this.practiceTitle,
    required this.practiceItems,
  });

  final String dayLabel;
  final String dateLine;
  final int completedCount;
  final int totalCount;
  final int streakDays;
  final String subtext;
  final String weekTitle;
  final int weekCompletedCount;
  final List<StreakWeekDay> weekDays;
  final StreakSocialCard socialCard;
  final String practiceTitle;
  final List<StreakPracticeItem> practiceItems;
}

abstract class StreakRepository {
  Future<StreakScreenState> fetchStreakScreen();
}

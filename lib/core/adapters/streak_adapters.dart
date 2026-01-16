import 'package:flutter/material.dart';

import '../adapters/screen_state_adapters.dart';
import '../repos/streak_repositories.dart';

class StreakWeekDayView {
  const StreakWeekDayView({
    required this.label,
    required this.isComplete,
    required this.isToday,
  });

  final String label;
  final bool isComplete;
  final bool isToday;
}

class StreakPracticeView {
  const StreakPracticeView({
    required this.id,
    required this.title,
    required this.icon,
    required this.isDone,
    required this.routePath,
  });

  final String id;
  final String title;
  final IconData icon;
  final bool isDone;
  final String? routePath;
}

class StreakAdapter {
  StreakAdapter(this.state);

  final StreakScreenState state;

  String get dayLabel => state.dayLabel;
  String get dateLine => state.dateLine;
  String get progressText =>
      '${state.completedCount}/${state.totalCount} COMPLETED';
  double get progressValue =>
      state.totalCount == 0 ? 0 : state.completedCount / state.totalCount;
  String get streakPillText => '${state.streakDays} day streak';
  String get subtext => state.subtext;
  String get weekTitle => state.weekTitle;
  String get weekProgressText => '${state.weekCompletedCount}/7';
  double get weekProgressValue => state.weekCompletedCount / 7;
  String get practiceTitle => state.practiceTitle;
  String get practiceProgressText =>
      '${state.completedCount}/${state.totalCount} completed';
  String get socialTitle => state.socialCard.title;
  String get socialSubtitle => state.socialCard.subtitle;

  List<StreakWeekDayView> get weekDays => state.weekDays
      .map(
        (day) => StreakWeekDayView(
          label: day.label,
          isComplete: day.isComplete,
          isToday: day.isToday,
        ),
      )
      .toList();

  List<StreakPracticeView> get practiceItems => state.practiceItems
      .map(
        (item) => StreakPracticeView(
          id: item.id,
          title: item.title,
          icon: iconDataFor(item.iconKey),
          isDone: item.isDone,
          routePath: item.routePath,
        ),
      )
      .toList();
}

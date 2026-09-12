import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/app/app_router.dart';
import 'package:tsion_orthodox_daily_app/app/route_paths.dart';
import 'package:tsion_orthodox_daily_app/core/config/feature_flags.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/models/ui_contract/ui_contract_models.dart';
import 'package:tsion_orthodox_daily_app/core/providers/repo_providers.dart';
import 'package:tsion_orthodox_daily_app/core/providers/screen_state_providers.dart';
import 'package:tsion_orthodox_daily_app/core/repos/fake/fake_calendar_repository.dart';
import 'package:tsion_orthodox_daily_app/core/repos/screen_states.dart';

void main() {
  testWidgets('Mezmur is hidden and its route redirects to Prayers', (
    tester,
  ) async {
    expect(FeatureFlags.mezmurEnabled, isFalse);
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(RoutePaths.mezmurPath());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.prayers);
    expect(find.text('Mezmur'), findsNothing);

    router.go(RoutePaths.today);
    await tester.pumpAndSettle();

    expect(find.text('Mezmur'), findsNothing);
    expect(find.text('Daily Tip'), findsNothing);
    expect(find.text('Ask a Question'), findsNothing);
    expect(find.text('Find Your Church'), findsNothing);
  });

  testWidgets('an unknown deep link returns to Today', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/route-that-does-not-exist');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.today);
  });

  testWidgets('account routes redirect to local Settings', (tester) async {
    expect(FeatureFlags.accountFeaturesEnabled, isFalse);
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(RoutePaths.profileSignInPath());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.settings);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('calendar day links open the selected day inline', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(RoutePaths.calendarDayPath('2026-02-12'));
    await tester.pumpAndSettle();

    final uri = router.routeInformationProvider.value.uri;
    expect(uri.path, RoutePaths.calendar);
    expect(uri.queryParameters['date'], '2026-02-12');
    final nextDay = find.bySemanticsLabel(RegExp(r'^2026-02-13'));
    expect(nextDay, findsOneWidget);
    await tester.tap(nextDay);
    await tester.pumpAndSettle();
    await tester.drag(find.text('Orthodox Calendar'), const Offset(0, -620));
    await tester.pumpAndSettle();
    expect(find.text('2026-02-13'), findsOneWidget);
    expect(find.text('Celebrations'), findsOneWidget);
    expect(find.text('Saints of the Day'), findsOneWidget);
    expect(find.text('Archangel Michael'), findsOneWidget);
    expect(find.text('St Michael'), findsOneWidget);
    expect(find.text('Spiritual Tracker'), findsNothing);
  });

  testWidgets('calendar arrows change month and preserve the selected day', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    final baseState = await FakeCalendarRepository().fetchCalendarScreen();
    final august = _testMonthGrid(
      year: 2026,
      month: 8,
      ethiopianMonth: 'Hamle',
    );
    final september = _testMonthGrid(
      year: 2026,
      month: 9,
      ethiopianMonth: 'Nehase',
    );
    final calendarState = _calendarStateWithMonths(baseState, [
      august,
      september,
    ]);
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
          calendarScreenStateProvider.overrideWith(
            (ref) => Future.value(calendarState),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(RoutePaths.calendarSelectedDayPath('2026-09-12'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.calendar);
    expect(find.text('Orthodox Calendar'), findsOneWidget);
    expect(find.byTooltip('Previous month'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('Aug 2026'), findsOneWidget);
    expect(find.text('2026-08-12'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();

    expect(find.text('Sep 2026'), findsOneWidget);
    expect(find.text('2026-09-12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

CalendarScreenState _calendarStateWithMonths(
  CalendarScreenState base,
  List<CalendarMonthGrid> months,
) {
  return CalendarScreenState(
    topBar: base.topBar,
    months: base.months,
    monthGrid: months.last,
    monthGrids: months,
    todayStatus: base.todayStatus,
    fastStatus: base.fastStatus,
    quickRules: base.quickRules,
    dailyReadings: base.dailyReadings,
    prayerOfDay: base.prayerOfDay,
    saintPreview: base.saintPreview,
    dayPlanner: base.dayPlanner,
    spiritualTracker: base.spiritualTracker,
    signals: base.signals,
    observances: base.observances,
    todayActions: base.todayActions,
    upcomingHeader: base.upcomingHeader,
    upcomingDays: base.upcomingDays,
  );
}

CalendarMonthGrid _testMonthGrid({
  required int year,
  required int month,
  required String ethiopianMonth,
}) {
  final firstDay = DateTime(year, month);
  final lastDay = DateTime(year, month + 1, 0);
  final gridStart = firstDay.subtract(Duration(days: firstDay.weekday % 7));
  final gridEnd = lastDay.add(Duration(days: 6 - (lastDay.weekday % 7)));
  final dayCount = gridEnd.difference(gridStart).inDays + 1;
  final weeks = <CalendarMonthWeek>[];

  for (var offset = 0; offset < dayCount; offset += 7) {
    weeks.add(
      CalendarMonthWeek(
        days: List.generate(7, (dayOffset) {
          final date = gridStart.add(Duration(days: offset + dayOffset));
          return CalendarMonthCell(
            gregorianDateKey: _testYmd(date),
            gregorianDay: date.day,
            ethiopianDay: ((date.day + 5) % 30) + 1,
            isCurrentMonth: date.month == month,
            isToday: date == DateTime(2026, 9, 12),
            hasDot:
                date.weekday == DateTime.wednesday ||
                date.weekday == DateTime.friday,
          );
        }),
      ),
    );
  }

  return CalendarMonthGrid(
    gregorianYear: year,
    gregorianMonth: month,
    ethiopianMonthLabel: ethiopianMonth,
    ethiopianYear: 2018,
    gregorianRangeLabel: '$month/$year',
    weekdayLabels: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    weeks: weeks,
  );
}

String _testYmd(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../features/today/today_screen.dart';
import '../features/bible/bible_screen.dart';
import '../features/prayers/prayers_screen.dart';
import '../features/calendar/calendar_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/bible',
            builder: (context, state) => const BibleScreen(),
          ),
          GoRoute(
            path: '/prayers',
            builder: (context, state) => const PrayersScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'route_paths.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/bible/presentation/bible_screen.dart';
import '../features/prayers/presentation/prayers_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.today,
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: RoutePaths.bible,
            builder: (context, state) => const BibleScreen(),
            routes: [
              GoRoute(
                path: 'reader/:book/:chapter',
                builder: (context, state) {
                  final book = state.pathParameters['book'] ?? '';
                  final chapter = state.pathParameters['chapter'] ?? '';

                  return Scaffold(
                    appBar: AppBar(title: const Text('Bible Reader')),
                    body: Center(child: Text('Book: $book, Chapter: $chapter')),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.prayers,
            builder: (context, state) => const PrayersScreen(),
          ),
          GoRoute(
            path: RoutePaths.calendar,
            builder: (context, state) => const CalendarScreen(),
          ),
        ],
      ),
    ],
  );
}

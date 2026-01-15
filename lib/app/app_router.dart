import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'route_paths.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/bible/presentation/bible_screen.dart';
import '../features/bible/presentation/book_detail_screen.dart';
import '../features/bible/presentation/reader_screen.dart';
import '../features/bible/presentation/bible_library_screen.dart';
import '../features/bible/presentation/bible_chapter_screen.dart';
import '../features/bible/presentation/passage_screen.dart';
import '../features/prayers/presentation/prayers_screen.dart';
import '../features/prayers/presentation/prayer_detail_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/calendar/calendar_day_detail_screen.dart';
import '../features/explore/presentation/explore_screen.dart';

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
                path: 'book/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'book';
                  return BookDetailScreen(title: _titleFromId(id));
                },
                routes: [
                  GoRoute(
                    path: 'reader',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'book';
                      return ReaderScreen(title: _titleFromId(id));
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'library',
                builder: (context, state) => const BibleLibraryScreen(),
                routes: [
                  GoRoute(
                    path: ':book',
                    builder: (context, state) {
                      final book = state.pathParameters['book'] ?? 'Book';
                      return BibleChapterScreen(book: _titleFromId(book));
                    },
                    routes: [
                      GoRoute(
                        path: ':chapter',
                        builder: (context, state) {
                          final book = state.pathParameters['book'] ?? 'Book';
                          final chapterValue =
                              state.pathParameters['chapter'] ?? '1';
                          final chapter = int.tryParse(chapterValue) ?? 1;
                          return PassageScreen(
                            book: _titleFromId(book),
                            chapter: chapter,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'reader/:book/:chapter',
                builder: (context, state) {
                  final book = state.pathParameters['book'] ?? '';
                  final chapter = state.pathParameters['chapter'] ?? '';

                  return PassageScreen(
                    book: _titleFromId(book),
                    chapter: int.tryParse(chapter) ?? 1,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.prayers,
            builder: (context, state) => const PrayersScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'prayer';
                  return PrayerDetailScreen(title: _titleFromId(id));
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.calendar,
            builder: (context, state) => const CalendarScreen(),
            routes: [
              GoRoute(
                path: 'day/:date',
                builder: (context, state) {
                  final date = state.pathParameters['date'] ?? 'Today';
                  return CalendarDayDetailScreen(date: date);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
        ],
      ),
    ],
  );
}

String _titleFromId(String id) {
  final words = id.split('-');
  return words
      .where((word) => word.isNotEmpty)
      .map(
        (word) => word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');
}

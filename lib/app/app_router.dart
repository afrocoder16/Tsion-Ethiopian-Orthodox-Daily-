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
import '../features/prayers/presentation/mezmur_screen.dart';
import '../features/prayers/presentation/daily_prayer_screen.dart';
import '../features/prayers/presentation/reflection_screen.dart';
import '../features/prayers/presentation/light_candle_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/calendar/calendar_day_detail_screen.dart';
import '../features/calendar/presentation/fasting_guidance_screen.dart';
import '../features/calendar/presentation/calendar_link_placeholder_screen.dart';
import '../features/calendar/presentation/synaxarium_screen.dart';
import '../features/calendar/presentation/synaxarium_bookmarks_screen.dart';
import '../features/calendar/presentation/synaxarium_entry_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/explore/presentation/explore_detail_screen.dart';
import '../features/explore/presentation/guided_path_detail_screen.dart';
import '../features/explore/presentation/community_entry_screen.dart';
import '../features/streak/presentation/streak_screen.dart';
import '../features/bible/presentation/patron_saint_screen.dart';

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
          ..._booksRoutes(),
          ..._legacyBibleRoutes(),
          GoRoute(
            path: RoutePaths.prayers,
            builder: (context, state) => const PrayersScreen(),
            routes: [
              GoRoute(
                path: 'daily',
                builder: (context, state) => const DailyPrayerScreen(),
              ),
              GoRoute(
                path: 'mezmur',
                builder: (context, state) => const MezmurScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'prayer';
                  return PrayerDetailScreen(prayerId: id);
                },
              ),
              GoRoute(
                path: 'reflection',
                builder: (context, state) => const ReflectionScreen(),
              ),
              GoRoute(
                path: 'light-candle',
                builder: (context, state) => const LightCandleScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.calendar,
            builder: (context, state) => const CalendarScreen(),
            routes: [
              GoRoute(
                path: 'fasting',
                builder: (context, state) => const FastingGuidanceScreen(),
              ),
              GoRoute(
                path: 'day/:date',
                builder: (context, state) {
                  final date = state.pathParameters['date'] ?? 'Today';
                  return CalendarDayDetailScreen(dateKey: date);
                },
                routes: [
                  GoRoute(
                    path: 'link/:type',
                    builder: (context, state) {
                      final date = state.pathParameters['date'] ?? 'Today';
                      final type = state.pathParameters['type'] ?? 'link';
                      return CalendarLinkPlaceholderScreen(
                        dateKey: date,
                        linkType: type,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'synaxarium/bookmarks',
                builder: (context, state) => const SynaxariumBookmarksScreen(),
              ),
              GoRoute(
                path: 'synaxarium/entry/:ethKey',
                builder: (context, state) {
                  final key = state.pathParameters['ethKey'] ?? '';
                  return SynaxariumEntryScreen(ethKey: key);
                },
              ),
              GoRoute(
                path: 'synaxarium/:date',
                builder: (context, state) {
                  final date = state.pathParameters['date'] ?? '';
                  return SynaxariumScreen(dateKey: date);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.explore,
            builder: (context, state) => const ExploreScreen(),
            routes: [
              GoRoute(
                path: 'item/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'item';
                  return ExploreDetailScreen(itemId: id);
                },
              ),
              GoRoute(
                path: 'path/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'path';
                  return GuidedPathDetailScreen(pathId: id);
                },
              ),
              GoRoute(
                path: 'community/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'community';
                  return CommunityEntryScreen(entryId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.streak,
        builder: (context, state) => const StreakScreen(),
      ),
      GoRoute(
        path: RoutePaths.patronSaint,
        builder: (context, state) {
          final rawName = state.pathParameters['name'] ?? 'Patron Saint';
          return PatronSaintScreen(name: Uri.decodeComponent(rawName));
        },
      ),
    ],
  );
}

List<GoRoute> _booksRoutes() {
  return [
    GoRoute(
      path: RoutePaths.booksRoot,
      builder: (context, state) => const BibleScreen(),
      routes: [
        GoRoute(
          path: 'book/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? 'book';
            return BookDetailScreen(bookId: id);
          },
        ),
        GoRoute(
          path: 'reader/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? 'book';
            return ReaderScreen(bookId: id);
          },
        ),
        GoRoute(
          path: 'bible',
          builder: (context, state) => const BibleLibraryScreen(),
          routes: [
            GoRoute(
              path: ':book',
              builder: (context, state) {
                final book = state.pathParameters['book'] ?? 'Book';
                return BibleChapterScreen(bookId: book);
              },
              routes: [
                GoRoute(
                  path: ':chapter',
                  builder: (context, state) {
                    final book = state.pathParameters['book'] ?? 'Book';
                    final chapterValue = state.pathParameters['chapter'] ?? '1';
                    final chapter = int.tryParse(chapterValue) ?? 1;
                    return PassageScreen(bookId: book, chapter: chapter);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}

List<GoRoute> _legacyBibleRoutes() {
  // Keep legacy /bible paths for compatibility and deep links.
  return [
    GoRoute(
      path: RoutePaths.legacyBibleRoot,
      builder: (context, state) => const BibleScreen(),
      routes: [
        GoRoute(
          path: 'book/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? 'book';
            return BookDetailScreen(bookId: id);
          },
        ),
        GoRoute(
          path: 'book/:id/reader',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? 'book';
            return ReaderScreen(bookId: id);
          },
        ),
        GoRoute(
          path: 'library',
          builder: (context, state) => const BibleLibraryScreen(),
          routes: [
            GoRoute(
              path: ':book',
              builder: (context, state) {
                final book = state.pathParameters['book'] ?? 'Book';
                return BibleChapterScreen(bookId: book);
              },
              routes: [
                GoRoute(
                  path: ':chapter',
                  builder: (context, state) {
                    final book = state.pathParameters['book'] ?? 'Book';
                    final chapterValue = state.pathParameters['chapter'] ?? '1';
                    final chapter = int.tryParse(chapterValue) ?? 1;
                    return PassageScreen(bookId: book, chapter: chapter);
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
              bookId: book,
              chapter: int.tryParse(chapter) ?? 1,
            );
          },
        ),
      ],
    ),
  ];
}

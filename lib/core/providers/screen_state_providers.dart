import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/screen_states.dart';
import 'repo_providers.dart';

final todayScreenStateProvider = FutureProvider<TodayScreenState>(
  (ref) async => ref.watch(todayRepositoryProvider).fetchTodayScreen(),
);

final booksScreenStateProvider = FutureProvider<BooksScreenState>(
  (ref) async => ref.watch(booksRepositoryProvider).fetchBooksScreen(),
);

final prayersScreenStateProvider = FutureProvider<PrayersScreenState>(
  (ref) async => ref.watch(prayersRepositoryProvider).fetchPrayersScreen(),
);

final calendarScreenStateProvider = FutureProvider<CalendarScreenState>(
  (ref) async => ref.watch(calendarRepositoryProvider).fetchCalendarScreen(),
);

final exploreScreenStateProvider = FutureProvider<ExploreScreenState>(
  (ref) async => ref.watch(exploreRepositoryProvider).fetchExploreScreen(),
);

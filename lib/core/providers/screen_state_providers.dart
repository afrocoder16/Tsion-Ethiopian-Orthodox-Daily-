import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/screen_state_adapters.dart';
import '../repos/screen_states.dart';
import 'repo_providers.dart';

final todayScreenStateProvider = FutureProvider<TodayScreenState>(
  (ref) async => ref.watch(todayRepositoryProvider).fetchTodayScreen(),
);

final dailyVersePageProvider = FutureProvider<DailyVersePageView>((ref) async {
  final todayState = await ref.watch(todayScreenStateProvider.future);
  final supportingEntries = await ref
      .watch(dailyVerseRepositoryProvider)
      .loadSupportingForDate(DateTime.now());
  return DailyVersePageView(
    verseCard: TodayAdapter(todayState).verseCard,
    supportingReadings: supportingEntries
        .map(
          (item) => DailyVerseSupportingItemView(
            label: item.label,
            reference: item.reference,
            body: item.previewBody,
            bookId: item.bookId,
            chapter: item.chapter,
            isPreviewTruncated: item.isPreviewTruncated,
          ),
        )
        .toList(growable: false),
  );
});

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

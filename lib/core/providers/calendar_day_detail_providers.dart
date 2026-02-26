import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/db/db_calendar_day_detail_repository.dart';
import '../repos/db/db_celebrations_repository.dart';
import '../repos/db/db_saints_repository.dart';
import '../repos/db/db_synaxarium_repository.dart';
import '../repos/celebrations_repository.dart';
import '../repos/calendar_day_detail_repositories.dart';
import '../repos/fake/fake_calendar_day_detail_repository.dart';
import '../repos/saints_repository.dart';
import '../repos/synaxarium_repository.dart';
import 'repo_providers.dart';

final celebrationsRepositoryProvider = Provider<CelebrationsRepository>((ref) {
  return DbCelebrationsRepository(engine: ref.watch(calendarEngineProvider));
});

final saintsRepositoryProvider = Provider<SaintsRepository>((ref) {
  return DbSaintsRepository();
});

final synaxariumRepositoryProvider = Provider<SynaxariumRepository>((ref) {
  return DbSynaxariumRepository(db: ref.watch(dbProvider));
});

final calendarDayDetailRepositoryProvider =
    Provider<CalendarDayDetailRepository>((ref) {
      final useDb = ref.watch(useDbReposProvider);
      if (!useDb) {
        return FakeCalendarDayDetailRepository();
      }
      return DbCalendarDayDetailRepository(
        db: ref.watch(dbProvider),
        engine: ref.watch(calendarEngineProvider),
        celebrationsRepository: ref.watch(celebrationsRepositoryProvider),
        saintsRepository: ref.watch(saintsRepositoryProvider),
      );
    });

final calendarDayDetailProvider = FutureProvider.family
    .autoDispose<CalendarDayDetailState, String>(
      (ref, dateKey) => ref
          .watch(calendarDayDetailRepositoryProvider)
          .fetchDayDetail(dateKey),
    );

final synaxariumEntryProvider = FutureProvider.family
    .autoDispose<SynaxariumEntry?, String>((ref, dateKey) async {
      final detail = await ref.watch(calendarDayDetailProvider(dateKey).future);
      return ref
          .watch(synaxariumRepositoryProvider)
          .fetchEntryForDate(detail.dayObservance.ethDate);
    });

final synaxariumBookmarkedProvider = FutureProvider.family
    .autoDispose<bool, String>((ref, dateKey) async {
      final entry = await ref.watch(synaxariumEntryProvider(dateKey).future);
      if (entry == null) {
        return false;
      }
      return ref.watch(synaxariumRepositoryProvider).isBookmarked(entry.key);
    });

final synaxariumBookmarksProvider = FutureProvider.autoDispose
    .family<List<SynaxariumBookmarkItem>, int>((ref, version) {
      return ref.watch(synaxariumRepositoryProvider).fetchBookmarks();
    });

final synaxariumEntryByKeyProvider = FutureProvider.family
    .autoDispose<SynaxariumEntry?, String>((ref, ethKey) {
      return ref.watch(synaxariumRepositoryProvider).fetchEntryByKey(ethKey);
    });

final synaxariumSnippetBookmarksAllProvider = FutureProvider.autoDispose
    .family<List<SynaxariumSnippetBookmark>, int>((ref, version) {
      return ref.watch(synaxariumRepositoryProvider).fetchSnippetBookmarks();
    });

final synaxariumSnippetBookmarksForEntryProvider = FutureProvider.autoDispose
    .family<List<SynaxariumSnippetBookmark>, ({String entryKey, int version})>(
      (ref, request) {
        return ref
            .watch(synaxariumRepositoryProvider)
            .fetchSnippetBookmarks(entryKey: request.entryKey);
      },
    );

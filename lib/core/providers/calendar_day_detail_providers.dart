import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/db/db_calendar_day_detail_repository.dart';
import '../repos/db/db_celebrations_repository.dart';
import '../repos/db/db_saints_repository.dart';
import '../repos/celebrations_repository.dart';
import '../repos/calendar_day_detail_repositories.dart';
import '../repos/fake/fake_calendar_day_detail_repository.dart';
import '../repos/saints_repository.dart';
import 'repo_providers.dart';

final celebrationsRepositoryProvider = Provider<CelebrationsRepository>((ref) {
  return DbCelebrationsRepository(engine: ref.watch(calendarEngineProvider));
});

final saintsRepositoryProvider = Provider<SaintsRepository>((ref) {
  return DbSaintsRepository();
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

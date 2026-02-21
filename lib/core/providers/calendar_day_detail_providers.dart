import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/db/db_calendar_day_detail_repository.dart';
import '../repos/calendar_day_detail_repositories.dart';
import '../repos/fake/fake_calendar_day_detail_repository.dart';
import 'repo_providers.dart';

final calendarDayDetailRepositoryProvider =
    Provider<CalendarDayDetailRepository>((ref) {
      final useDb = ref.watch(useDbReposProvider);
      if (!useDb) {
        return FakeCalendarDayDetailRepository();
      }
      return DbCalendarDayDetailRepository(
        db: ref.watch(dbProvider),
        engine: ref.watch(calendarEngineProvider),
      );
    });

final calendarDayDetailProvider = FutureProvider.family
    .autoDispose<CalendarDayDetailState, String>(
      (ref, dateKey) => ref
          .watch(calendarDayDetailRepositoryProvider)
          .fetchDayDetail(dateKey),
    );

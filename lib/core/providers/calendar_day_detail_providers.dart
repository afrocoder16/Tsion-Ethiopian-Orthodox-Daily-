import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/calendar_day_detail_repositories.dart';
import '../repos/fake/fake_calendar_day_detail_repository.dart';

final calendarDayDetailRepositoryProvider =
    Provider<CalendarDayDetailRepository>(
  (ref) => FakeCalendarDayDetailRepository(),
);

final calendarDayDetailProvider =
    FutureProvider.family.autoDispose<CalendarDayDetailState, String>(
  (ref, dateKey) =>
      ref.watch(calendarDayDetailRepositoryProvider).fetchDayDetail(dateKey),
);

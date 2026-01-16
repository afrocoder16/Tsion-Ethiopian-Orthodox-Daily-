import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/daos/prayer_completions_dao.dart';
import '../providers/repo_providers.dart';
import '../repos/db/db_prayer_detail_repository.dart';
import '../repos/fake/fake_prayer_detail_repository.dart';
import '../repos/prayer_flow_repositories.dart';

final prayerDetailRepositoryProvider = Provider<PrayerDetailRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (useDb) {
      return DbPrayerDetailRepository(ref.watch(dbProvider));
    }
    return FakePrayerDetailRepository();
  },
);

final prayerDetailProvider =
    FutureProvider.family.autoDispose<PrayerDetailState, String>(
  (ref, id) => ref.watch(prayerDetailRepositoryProvider).fetchDetail(id),
);

final recentPrayerIdProvider = FutureProvider.autoDispose<String>((ref) async {
  final db = ref.watch(dbProvider);
  final todayYmd = _formatYmd(DateTime.now());
  final rows = await PrayerCompletionsDao(db).listTodaysCompletions(todayYmd);
  if (rows.isEmpty) {
    return 'prayer-midday';
  }
  final last = rows.last;
  return idForSlotId(last.slotId);
});

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

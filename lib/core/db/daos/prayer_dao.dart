import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/prayer_completions.dart';
import '../tables/prayer_schedule.dart';

part 'prayer_dao.g.dart';

@DriftAccessor(tables: [PrayerSchedule, PrayerCompletions])
class PrayerDao extends DatabaseAccessor<AppDatabase> with _$PrayerDaoMixin {
  PrayerDao(super.db);

  Future<void> addPrayerCompletion({
    required String dateYmd,
    required int slotId,
    required String completedAtIso,
  }) {
    return into(prayerCompletions).insertOnConflictUpdate(
      PrayerCompletionsCompanion(
        dateYmd: Value(dateYmd),
        slotId: Value(slotId),
        completedAtIso: Value(completedAtIso),
      ),
    );
  }

  Future<List<PrayerCompletion>> listTodaysCompletions(String dateYmd) {
    return (select(prayerCompletions)..where((tbl) => tbl.dateYmd.equals(dateYmd)))
        .get();
  }
}

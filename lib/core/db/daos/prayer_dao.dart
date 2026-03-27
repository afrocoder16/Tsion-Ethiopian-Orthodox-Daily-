import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/prayer_completions.dart';
import '../tables/prayer_schedule.dart';

part 'prayer_dao.g.dart';

@DriftAccessor(tables: [PrayerSchedule, PrayerCompletions])
class PrayerDao extends DatabaseAccessor<AppDatabase> with _$PrayerDaoMixin {
  PrayerDao(super.db);

  static const List<(int, String, String, bool)> _defaultPrayerSchedule = [
    (1, 'Morning', '06:00', true),
    (2, 'Noon', '12:00', true),
    (3, 'Evening', '18:00', true),
    (4, 'Night', '21:00', false),
  ];

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
    return (select(
      prayerCompletions,
    )..where((tbl) => tbl.dateYmd.equals(dateYmd))).get();
  }

  Future<List<PrayerScheduleData>> listPrayerSchedule() {
    return (select(
      prayerSchedule,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.slotId)])).get();
  }

  Future<void> ensureDefaultPrayerSchedule() async {
    final existing = await listPrayerSchedule();
    if (existing.isNotEmpty) {
      return;
    }
    await batch((batch) {
      batch.insertAll(
        prayerSchedule,
        _defaultPrayerSchedule
            .map(
              (slot) => PrayerScheduleCompanion.insert(
                slotId: Value(slot.$1),
                label: slot.$2,
                timeLocal: slot.$3,
                isEnabled: slot.$4,
              ),
            )
            .toList(),
      );
    });
  }

  Future<void> upsertPrayerSlot({
    required int slotId,
    required String label,
    required String timeLocal,
    required bool isEnabled,
  }) {
    return into(prayerSchedule).insertOnConflictUpdate(
      PrayerScheduleCompanion(
        slotId: Value(slotId),
        label: Value(label),
        timeLocal: Value(timeLocal),
        isEnabled: Value(isEnabled),
      ),
    );
  }
}

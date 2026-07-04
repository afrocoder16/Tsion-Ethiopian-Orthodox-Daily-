import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/personal_prayers.dart';

part 'personal_prayers_dao.g.dart';

@DriftAccessor(tables: [PersonalPrayers])
class PersonalPrayersDao extends DatabaseAccessor<AppDatabase>
    with _$PersonalPrayersDaoMixin {
  PersonalPrayersDao(super.db);

  Future<void> upsertPersonalPrayer({
    required String id,
    required String name,
    required String intention,
    required String createdAtIso,
    required String updatedAtIso,
    String? dueAtIso,
  }) {
    return into(personalPrayers).insertOnConflictUpdate(
      PersonalPrayersCompanion(
        id: Value(id),
        name: Value(name),
        intention: Value(intention),
        createdAtIso: Value(createdAtIso),
        updatedAtIso: Value(updatedAtIso),
        dueAtIso: Value(dueAtIso),
      ),
    );
  }

  Future<int> deletePersonalPrayer(String id) {
    return (delete(personalPrayers)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<PersonalPrayer>> listPersonalPrayers() {
    return (select(
      personalPrayers,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.updatedAtIso)])).get();
  }

  Stream<List<PersonalPrayer>> watchPersonalPrayers() {
    return (select(
      personalPrayers,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.updatedAtIso)])).watch();
  }
}

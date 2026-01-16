import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/prayer_completions.dart';

part 'prayer_completions_dao.g.dart';

@DriftAccessor(tables: [PrayerCompletions])
class PrayerCompletionsDao extends DatabaseAccessor<AppDatabase>
    with _$PrayerCompletionsDaoMixin {
  PrayerCompletionsDao(super.db);

  Future<List<PrayerCompletion>> listTodaysCompletions(String dateYmd) {
    return (select(prayerCompletions)..where((tbl) => tbl.dateYmd.equals(dateYmd)))
        .get();
  }
}

import 'package:drift/drift.dart';

class PrayerCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dateYmd => text().named('date_ymd')();
  IntColumn get slotId => integer().named('slot_id')();
  TextColumn get completedAtIso => text().named('completed_at_iso')();

  @override
  List<String> get customConstraints => [
        'UNIQUE(date_ymd, slot_id)',
      ];
}

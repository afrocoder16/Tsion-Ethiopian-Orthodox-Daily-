import 'package:drift/drift.dart';

class PrayerSchedule extends Table {
  IntColumn get slotId => integer().autoIncrement().named('slot_id')();
  TextColumn get label => text()();
  TextColumn get timeLocal => text().named('time_local')();
  BoolColumn get isEnabled => boolean().named('is_enabled')();
}

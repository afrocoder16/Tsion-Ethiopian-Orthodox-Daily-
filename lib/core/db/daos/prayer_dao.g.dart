// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_dao.dart';

// ignore_for_file: type=lint
mixin _$PrayerDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrayerScheduleTable get prayerSchedule => attachedDatabase.prayerSchedule;
  $PrayerCompletionsTable get prayerCompletions =>
      attachedDatabase.prayerCompletions;
  PrayerDaoManager get managers => PrayerDaoManager(this);
}

class PrayerDaoManager {
  final _$PrayerDaoMixin _db;
  PrayerDaoManager(this._db);
  $$PrayerScheduleTableTableManager get prayerSchedule =>
      $$PrayerScheduleTableTableManager(
        _db.attachedDatabase,
        _db.prayerSchedule,
      );
  $$PrayerCompletionsTableTableManager get prayerCompletions =>
      $$PrayerCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.prayerCompletions,
      );
}

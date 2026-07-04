// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_prayers_dao.dart';

// ignore_for_file: type=lint
mixin _$PersonalPrayersDaoMixin on DatabaseAccessor<AppDatabase> {
  $PersonalPrayersTable get personalPrayers => attachedDatabase.personalPrayers;
  PersonalPrayersDaoManager get managers => PersonalPrayersDaoManager(this);
}

class PersonalPrayersDaoManager {
  final _$PersonalPrayersDaoMixin _db;
  PersonalPrayersDaoManager(this._db);
  $$PersonalPrayersTableTableManager get personalPrayers =>
      $$PersonalPrayersTableTableManager(
        _db.attachedDatabase,
        _db.personalPrayers,
      );
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_completions_dao.dart';

// ignore_for_file: type=lint
mixin _$PrayerCompletionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrayerCompletionsTable get prayerCompletions =>
      attachedDatabase.prayerCompletions;
  PrayerCompletionsDaoManager get managers => PrayerCompletionsDaoManager(this);
}

class PrayerCompletionsDaoManager {
  final _$PrayerCompletionsDaoMixin _db;
  PrayerCompletionsDaoManager(this._db);
  $$PrayerCompletionsTableTableManager get prayerCompletions =>
      $$PrayerCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.prayerCompletions,
      );
}

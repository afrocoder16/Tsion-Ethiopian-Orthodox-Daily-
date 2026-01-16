// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_events_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakEventsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StreakTasksTable get streakTasks => attachedDatabase.streakTasks;
  $StreakEventsTable get streakEvents => attachedDatabase.streakEvents;
  StreakEventsDaoManager get managers => StreakEventsDaoManager(this);
}

class StreakEventsDaoManager {
  final _$StreakEventsDaoMixin _db;
  StreakEventsDaoManager(this._db);
  $$StreakTasksTableTableManager get streakTasks =>
      $$StreakTasksTableTableManager(_db.attachedDatabase, _db.streakTasks);
  $$StreakEventsTableTableManager get streakEvents =>
      $$StreakEventsTableTableManager(_db.attachedDatabase, _db.streakEvents);
}

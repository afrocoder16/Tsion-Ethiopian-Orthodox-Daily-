// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakDaoMixin on DatabaseAccessor<AppDatabase> {
  $StreakTasksTable get streakTasks => attachedDatabase.streakTasks;
  $StreakEventsTable get streakEvents => attachedDatabase.streakEvents;
  StreakDaoManager get managers => StreakDaoManager(this);
}

class StreakDaoManager {
  final _$StreakDaoMixin _db;
  StreakDaoManager(this._db);
  $$StreakTasksTableTableManager get streakTasks =>
      $$StreakTasksTableTableManager(_db.attachedDatabase, _db.streakTasks);
  $$StreakEventsTableTableManager get streakEvents =>
      $$StreakEventsTableTableManager(_db.attachedDatabase, _db.streakEvents);
}

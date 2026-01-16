import 'package:drift/drift.dart';

class StreakEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dateYmd => text().named('date_ymd')();
  TextColumn get taskId => text().named('task_id')();
  TextColumn get completedAtIso => text().named('completed_at_iso')();

  @override
  List<String> get customConstraints => [
        'UNIQUE(date_ymd, task_id)',
      ];
}

import 'package:drift/drift.dart';

class StreakTasks extends Table {
  TextColumn get taskId => text().named('task_id')();
  TextColumn get title => text()();
  BoolColumn get isRequired => boolean().named('is_required')();

  @override
  Set<Column> get primaryKey => {taskId};
}

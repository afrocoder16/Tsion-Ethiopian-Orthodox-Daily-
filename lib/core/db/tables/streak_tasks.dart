import 'package:drift/drift.dart';

class StreakTasks extends Table {
  TextColumn get taskId => text().named('task_id')();
  TextColumn get title => text()();
  BoolColumn get isRequired => boolean().named('is_required')();
  BoolColumn get isBonus =>
      boolean().named('is_bonus').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {taskId};
}

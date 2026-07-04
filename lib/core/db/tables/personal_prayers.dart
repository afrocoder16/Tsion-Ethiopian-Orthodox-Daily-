import 'package:drift/drift.dart';

class PersonalPrayers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get intention => text()();
  TextColumn get createdAtIso => text().named('created_at_iso')();
  TextColumn get updatedAtIso => text().named('updated_at_iso')();
  TextColumn get dueAtIso => text().nullable().named('due_at_iso')();

  @override
  Set<Column> get primaryKey => {id};
}

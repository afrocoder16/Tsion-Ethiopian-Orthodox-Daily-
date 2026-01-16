import 'package:drift/drift.dart';

class SavedItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  TextColumn get createdAtIso => text().named('created_at_iso')();

  @override
  Set<Column> get primaryKey => {id};
}

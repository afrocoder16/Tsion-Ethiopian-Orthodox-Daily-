import 'package:drift/drift.dart';

@DataClassName('BibleBookRow')
class BibleBooks extends Table {
  TextColumn get id => text()();
  TextColumn get canonId => text().named('canon_id')();
  TextColumn get testament => text()();
  IntColumn get orderIndex => integer().named('order_index')();
  TextColumn get nameEn => text().named('name_en')();
  TextColumn get nameAm => text().named('name_am')();
  TextColumn get abbrevEn => text().named('abbrev_en')();
  TextColumn get abbrevAm => text().named('abbrev_am')();
  IntColumn get chapters => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

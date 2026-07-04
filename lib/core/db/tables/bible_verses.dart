import 'package:drift/drift.dart';

@DataClassName('BibleVerseRow')
class BibleVerses extends Table {
  TextColumn get bookId => text().named('book_id')();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get textEn => text().named('text_en')();
  TextColumn get textAm => text().named('text_am')();

  @override
  Set<Column> get primaryKey => {bookId, chapter, verse};
}

import 'package:drift/drift.dart';

class ReadingProgress extends Table {
  TextColumn get bookId => text().named('book_id')();
  TextColumn get lastLocation => text().named('last_location')();
  TextColumn get progressText => text().named('progress_text')();
  TextColumn get updatedAtIso => text().named('updated_at_iso')();

  @override
  Set<Column> get primaryKey => {bookId};
}

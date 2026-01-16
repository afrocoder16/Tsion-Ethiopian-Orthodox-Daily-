import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reading_progress.dart';

part 'reading_progress_dao.g.dart';

@DriftAccessor(tables: [ReadingProgress])
class ReadingProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingProgressDaoMixin {
  ReadingProgressDao(super.db);

  Future<void> upsertReadingProgress({
    required String bookId,
    required String lastLocation,
    required String progressText,
    required String updatedAtIso,
  }) {
    return into(readingProgress).insertOnConflictUpdate(
      ReadingProgressCompanion(
        bookId: Value(bookId),
        lastLocation: Value(lastLocation),
        progressText: Value(progressText),
        updatedAtIso: Value(updatedAtIso),
      ),
    );
  }

  Future<ReadingProgressData?> getReadingProgress(String bookId) {
    return (select(readingProgress)..where((tbl) => tbl.bookId.equals(bookId)))
        .getSingleOrNull();
  }
}

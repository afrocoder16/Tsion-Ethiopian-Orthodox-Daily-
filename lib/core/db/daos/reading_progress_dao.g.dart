// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadingProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReadingProgressTable get readingProgress => attachedDatabase.readingProgress;
  ReadingProgressDaoManager get managers => ReadingProgressDaoManager(this);
}

class ReadingProgressDaoManager {
  final _$ReadingProgressDaoMixin _db;
  ReadingProgressDaoManager(this._db);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(
        _db.attachedDatabase,
        _db.readingProgress,
      );
}

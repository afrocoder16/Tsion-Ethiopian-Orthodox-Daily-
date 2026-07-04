// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_dao.dart';

// ignore_for_file: type=lint
mixin _$BibleDaoMixin on DatabaseAccessor<AppDatabase> {
  $BibleBooksTable get bibleBooks => attachedDatabase.bibleBooks;
  $BibleVersesTable get bibleVerses => attachedDatabase.bibleVerses;
  BibleDaoManager get managers => BibleDaoManager(this);
}

class BibleDaoManager {
  final _$BibleDaoMixin _db;
  BibleDaoManager(this._db);
  $$BibleBooksTableTableManager get bibleBooks =>
      $$BibleBooksTableTableManager(_db.attachedDatabase, _db.bibleBooks);
  $$BibleVersesTableTableManager get bibleVerses =>
      $$BibleVersesTableTableManager(_db.attachedDatabase, _db.bibleVerses);
}

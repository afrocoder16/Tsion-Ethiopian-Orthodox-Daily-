// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_dao.dart';

// ignore_for_file: type=lint
mixin _$MetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $MetaTable get meta => attachedDatabase.meta;
  MetaDaoManager get managers => MetaDaoManager(this);
}

class MetaDaoManager {
  final _$MetaDaoMixin _db;
  MetaDaoManager(this._db);
  $$MetaTableTableManager get meta =>
      $$MetaTableTableManager(_db.attachedDatabase, _db.meta);
}

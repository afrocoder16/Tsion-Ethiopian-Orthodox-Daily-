// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_items_dao.dart';

// ignore_for_file: type=lint
mixin _$SavedItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavedItemsTable get savedItems => attachedDatabase.savedItems;
  SavedItemsDaoManager get managers => SavedItemsDaoManager(this);
}

class SavedItemsDaoManager {
  final _$SavedItemsDaoMixin _db;
  SavedItemsDaoManager(this._db);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db.attachedDatabase, _db.savedItems);
}

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/saved_items.dart';

part 'saved_items_dao.g.dart';

@DriftAccessor(tables: [SavedItems])
class SavedItemsDao extends DatabaseAccessor<AppDatabase>
    with _$SavedItemsDaoMixin {
  SavedItemsDao(super.db);

  Future<void> addSavedItem({
    required String id,
    required String title,
    required String kind,
    required String createdAtIso,
    String? body,
  }) {
    return into(savedItems).insertOnConflictUpdate(
      SavedItemsCompanion(
        id: Value(id),
        title: Value(title),
        kind: Value(kind),
        createdAtIso: Value(createdAtIso),
        body: Value(body),
      ),
    );
  }

  Future<int> removeSavedItem(String id) {
    return (delete(savedItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<SavedItem>> listSavedItems() {
    return select(savedItems).get();
  }

  Stream<List<SavedItem>> watchSavedItems() {
    return select(savedItems).watch();
  }

  Stream<List<SavedItem>> watchByKind(String kind) {
    return (select(savedItems)..where((tbl) => tbl.kind.equals(kind))).watch();
  }

  Future<bool> isItemSaved(String id) async {
    final item = await (select(savedItems)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return item != null;
  }
}

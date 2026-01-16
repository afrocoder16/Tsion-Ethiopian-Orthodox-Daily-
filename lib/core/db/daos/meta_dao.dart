import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meta.dart';

part 'meta_dao.g.dart';

@DriftAccessor(tables: [Meta])
class MetaDao extends DatabaseAccessor<AppDatabase> with _$MetaDaoMixin {
  MetaDao(super.db);

  Future<void> upsertMeta(String key, String value) {
    return into(meta).insertOnConflictUpdate(
      MetaCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<String?> readMeta(String key) async {
    final row = await (select(meta)..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }
}

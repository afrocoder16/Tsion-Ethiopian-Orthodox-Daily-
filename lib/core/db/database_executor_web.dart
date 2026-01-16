import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

QueryExecutor openExecutorImpl() {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
    );
    sqlite3.registerVirtualFileSystem(
      InMemoryFileSystem(),
      makeDefault: true,
    );
    return WasmDatabase.inMemory(sqlite3);
  });
}

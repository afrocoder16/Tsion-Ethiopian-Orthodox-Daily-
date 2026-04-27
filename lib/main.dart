import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app/app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/providers/firebase_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  final firebaseBootstrap = await FirebaseBootstrap.initialize();
  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapProvider.overrideWithValue(firebaseBootstrap),
      ],
      child: const TsionApp(),
    ),
  );
}

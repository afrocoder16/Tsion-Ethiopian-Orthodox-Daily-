import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/app/app_router.dart';
import 'package:tsion_orthodox_daily_app/app/route_paths.dart';
import 'package:tsion_orthodox_daily_app/core/config/feature_flags.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/providers/repo_providers.dart';

void main() {
  testWidgets('Mezmur is hidden and its route redirects to Prayers', (
    tester,
  ) async {
    expect(FeatureFlags.mezmurEnabled, isFalse);
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go(RoutePaths.mezmurPath());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.prayers);
    expect(find.text('Mezmur'), findsNothing);

    router.go(RoutePaths.today);
    await tester.pumpAndSettle();

    expect(find.text('Mezmur'), findsNothing);
    expect(find.text('Daily Tip'), findsNothing);
    expect(find.text('Ask a Question'), findsNothing);
    expect(find.text('Find Your Church'), findsNothing);
  });

  testWidgets('an unknown deep link returns to Today', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final router = buildRouter();
    addTearDown(db.close);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          useDbReposProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/route-that-does-not-exist');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RoutePaths.today);
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsion_orthodox_daily_app/core/auth/models/auth_models.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/models/calendar_display_mode.dart';
import 'package:tsion_orthodox_daily_app/core/providers/auth_providers.dart';
import 'package:tsion_orthodox_daily_app/core/providers/prayer_flow_providers.dart';
import 'package:tsion_orthodox_daily_app/core/providers/repo_providers.dart';
import 'package:tsion_orthodox_daily_app/core/providers/sync_providers.dart';
import 'package:tsion_orthodox_daily_app/core/repos/fake/fake_prayer_detail_repository.dart';
import 'package:tsion_orthodox_daily_app/core/strings/app_strings.dart';
import 'package:tsion_orthodox_daily_app/features/prayers/presentation/prayer_detail_screen.dart';

void main() {
  testWidgets('signed-out user tapping Bookmark gets the prompt', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_testApp(db: db, session: AuthSession.signedOut()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.signInUnlockTitle), findsOneWidget);
    expect(await db.savedItemsDao.listSavedItems(), isEmpty);
  });

  testWidgets('signed-in user tapping Bookmark saves it', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_testApp(db: db, session: _signedInSession()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();

    final saved = await db.savedItemsDao.listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.id, 'prayer-midday');
  });

  testWidgets('signed-out user can read a prayer without a prompt', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_testApp(db: db, session: AuthSession.signedOut()));
    await tester.pumpAndSettle();

    expect(find.text('Prayer Text'), findsOneWidget);
    expect(find.textContaining('This is placeholder text'), findsOneWidget);
    expect(find.text(AppStrings.signInUnlockTitle), findsNothing);
  });
}

Widget _testApp({required AppDatabase db, required AuthSession session}) {
  return ProviderScope(
    overrides: [
      dbProvider.overrideWithValue(db),
      prayerDetailRepositoryProvider.overrideWith(
        (ref) => FakePrayerDetailRepository(),
      ),
      authSessionProvider.overrideWith(
        (ref) => Stream<AuthSession>.value(session),
      ),
      userDataSyncServiceProvider.overrideWith((ref) => Future.value(null)),
    ],
    child: const MaterialApp(
      home: PrayerDetailScreen(prayerId: 'prayer-midday'),
    ),
  );
}

AuthSession _signedInSession() {
  return AuthSession.signedIn(
    user: const AuthUser(
      uid: 'user-1',
      email: 'user@example.com',
      displayName: 'Tsion User',
      isAnonymous: false,
      providers: ['password'],
    ),
    preferences: const AccountPreferences(
      calendarDisplayMode: CalendarDisplayMode.ethiopian,
    ),
  );
}

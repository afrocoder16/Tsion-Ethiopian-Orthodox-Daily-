import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/core/actions/user_actions.dart';
import 'package:tsion_orthodox_daily_app/core/db/app_database.dart';
import 'package:tsion_orthodox_daily_app/core/sync/user_data_sync.dart';

void main() {
  test('local bookmark write mirrors to remote store', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _MemoryUserDataRemoteStore();
    final sync = UserDataSyncService(db: db, uid: 'user-1', remote: remote);

    await toggleSave(
      db: db,
      id: 'bookmark-1',
      title: 'Genesis 1',
      kind: 'bookmark',
      createdAtIso: '2026-01-01T00:00:00.000',
      sync: sync,
    );

    expect(await db.savedItemsDao.listSavedItems(), hasLength(1));
    expect(remote.bookmarks['bookmark-1']?.title, 'Genesis 1');
  });

  test('remote bookmark change pulls to local database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _MemoryUserDataRemoteStore()
      ..bookmarks['remote-1'] = const SyncBookmark(
        id: 'remote-1',
        title: 'Psalm 50',
        kind: 'bookmark',
        createdAtIso: '2026-01-01T00:00:00.000',
        updatedAtIso: '2026-01-01T00:00:01.000',
      );
    final sync = UserDataSyncService(db: db, uid: 'user-1', remote: remote);

    await sync.pullRemoteChanges();

    final saved = await db.savedItemsDao.listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.id, 'remote-1');
  });

  test('offline write queues and flushes on reconnect', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _MemoryUserDataRemoteStore()..failWrites = true;
    final sync = UserDataSyncService(db: db, uid: 'user-1', remote: remote);

    await toggleSave(
      db: db,
      id: 'queued-1',
      title: 'Queued Bookmark',
      kind: 'bookmark',
      createdAtIso: '2026-01-01T00:00:00.000',
      sync: sync,
    );

    expect(remote.bookmarks, isEmpty);
    expect(await sync.pendingQueueCount(), 1);

    remote.failWrites = false;
    await sync.flushQueue();

    expect(remote.bookmarks['queued-1']?.title, 'Queued Bookmark');
    expect(await sync.pendingQueueCount(), 0);
  });

  test('personal prayer write mirrors to remote store', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _MemoryUserDataRemoteStore();
    final sync = UserDataSyncService(db: db, uid: 'user-1', remote: remote);

    await savePersonalPrayer(
      db: db,
      id: 'prayer-1',
      name: 'Family',
      intention: 'Healing',
      createdAtIso: '2026-01-01T00:00:00.000',
      updatedAtIso: '2026-01-01T00:00:01.000',
      sync: sync,
    );

    expect(await db.personalPrayersDao.listPersonalPrayers(), hasLength(1));
    expect(remote.personalPrayers['prayer-1']?.intention, 'Healing');
  });

  test('remote personal prayer change pulls to local database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _MemoryUserDataRemoteStore()
      ..personalPrayers['remote-prayer'] = const SyncPersonalPrayer(
        id: 'remote-prayer',
        name: 'Mother',
        intention: 'Strength',
        createdAtIso: '2026-01-01T00:00:00.000',
        updatedAtIso: '2026-01-01T00:00:01.000',
      );
    final sync = UserDataSyncService(db: db, uid: 'user-1', remote: remote);

    await sync.pullRemoteChanges();

    final prayers = await db.personalPrayersDao.listPersonalPrayers();
    expect(prayers, hasLength(1));
    expect(prayers.single.name, 'Mother');
  });
}

class _MemoryUserDataRemoteStore implements UserDataRemoteStore {
  final bookmarks = <String, SyncBookmark>{};
  final streakEvents = <String, SyncStreakEvent>{};
  final prayerCompletions = <String, SyncPrayerCompletion>{};
  final prayerSchedule = <String, SyncPrayerScheduleSlot>{};
  final personalPrayers = <String, SyncPersonalPrayer>{};
  bool failWrites = false;

  @override
  Future<void> putBookmark(String uid, SyncBookmark bookmark) async {
    _checkWritable();
    bookmarks[bookmark.id] = bookmark;
  }

  @override
  Future<void> putPersonalPrayer(String uid, SyncPersonalPrayer prayer) async {
    _checkWritable();
    personalPrayers[prayer.id] = prayer;
  }

  @override
  Future<void> putPrayerCompletion(
    String uid,
    SyncPrayerCompletion completion,
  ) async {
    _checkWritable();
    prayerCompletions[completion.id] = completion;
  }

  @override
  Future<void> putPrayerScheduleSlot(
    String uid,
    SyncPrayerScheduleSlot slot,
  ) async {
    _checkWritable();
    prayerSchedule[slot.id] = slot;
  }

  @override
  Future<void> putStreakEvent(String uid, SyncStreakEvent event) async {
    _checkWritable();
    streakEvents[event.id] = event;
  }

  @override
  Future<UserDataSnapshot> pullUserData(String uid) async {
    return UserDataSnapshot(
      bookmarks: bookmarks.values.toList(),
      streakEvents: streakEvents.values.toList(),
      prayerCompletions: prayerCompletions.values.toList(),
      prayerSchedule: prayerSchedule.values.toList(),
      personalPrayers: personalPrayers.values.toList(),
    );
  }

  void _checkWritable() {
    if (failWrites) {
      throw StateError('Remote unavailable');
    }
  }
}

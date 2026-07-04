import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../db/app_database.dart';

class SyncBookmark {
  const SyncBookmark({
    required this.id,
    required this.title,
    required this.kind,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.body,
    this.deleted = false,
  });

  final String id;
  final String title;
  final String kind;
  final String createdAtIso;
  final String updatedAtIso;
  final String? body;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'kind': kind,
    'createdAtIso': createdAtIso,
    'updatedAtIso': updatedAtIso,
    'body': body,
    'deleted': deleted,
  };

  factory SyncBookmark.fromJson(Map<String, dynamic> json) {
    return SyncBookmark(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      kind: '${json['kind'] ?? ''}',
      createdAtIso: '${json['createdAtIso'] ?? ''}',
      updatedAtIso: '${json['updatedAtIso'] ?? json['createdAtIso'] ?? ''}',
      body: json['body'] as String?,
      deleted: json['deleted'] == true,
    );
  }
}

class SyncStreakEvent {
  const SyncStreakEvent({
    required this.dateYmd,
    required this.taskId,
    required this.completedAtIso,
    required this.updatedAtIso,
    this.deleted = false,
  });

  final String dateYmd;
  final String taskId;
  final String completedAtIso;
  final String updatedAtIso;
  final bool deleted;

  String get id => '${dateYmd}_$taskId';

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateYmd': dateYmd,
    'taskId': taskId,
    'completedAtIso': completedAtIso,
    'updatedAtIso': updatedAtIso,
    'deleted': deleted,
  };

  factory SyncStreakEvent.fromJson(Map<String, dynamic> json) {
    return SyncStreakEvent(
      dateYmd: '${json['dateYmd'] ?? ''}',
      taskId: '${json['taskId'] ?? ''}',
      completedAtIso: '${json['completedAtIso'] ?? ''}',
      updatedAtIso: '${json['updatedAtIso'] ?? json['completedAtIso'] ?? ''}',
      deleted: json['deleted'] == true,
    );
  }
}

class SyncPrayerCompletion {
  const SyncPrayerCompletion({
    required this.dateYmd,
    required this.slotId,
    required this.completedAtIso,
    required this.updatedAtIso,
    this.deleted = false,
  });

  final String dateYmd;
  final int slotId;
  final String completedAtIso;
  final String updatedAtIso;
  final bool deleted;

  String get id => '${dateYmd}_$slotId';

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateYmd': dateYmd,
    'slotId': slotId,
    'completedAtIso': completedAtIso,
    'updatedAtIso': updatedAtIso,
    'deleted': deleted,
  };

  factory SyncPrayerCompletion.fromJson(Map<String, dynamic> json) {
    return SyncPrayerCompletion(
      dateYmd: '${json['dateYmd'] ?? ''}',
      slotId: _readInt(json['slotId']),
      completedAtIso: '${json['completedAtIso'] ?? ''}',
      updatedAtIso: '${json['updatedAtIso'] ?? json['completedAtIso'] ?? ''}',
      deleted: json['deleted'] == true,
    );
  }
}

class SyncPrayerScheduleSlot {
  const SyncPrayerScheduleSlot({
    required this.slotId,
    required this.label,
    required this.timeLocal,
    required this.isEnabled,
    required this.updatedAtIso,
  });

  final int slotId;
  final String label;
  final String timeLocal;
  final bool isEnabled;
  final String updatedAtIso;

  String get id => '$slotId';

  Map<String, dynamic> toJson() => {
    'id': id,
    'slotId': slotId,
    'label': label,
    'timeLocal': timeLocal,
    'isEnabled': isEnabled,
    'updatedAtIso': updatedAtIso,
  };

  factory SyncPrayerScheduleSlot.fromJson(Map<String, dynamic> json) {
    return SyncPrayerScheduleSlot(
      slotId: _readInt(json['slotId']),
      label: '${json['label'] ?? ''}',
      timeLocal: '${json['timeLocal'] ?? ''}',
      isEnabled: json['isEnabled'] == true,
      updatedAtIso: '${json['updatedAtIso'] ?? ''}',
    );
  }
}

class SyncPersonalPrayer {
  const SyncPersonalPrayer({
    required this.id,
    required this.name,
    required this.intention,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.dueAtIso,
    this.deleted = false,
  });

  final String id;
  final String name;
  final String intention;
  final String createdAtIso;
  final String updatedAtIso;
  final String? dueAtIso;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'intention': intention,
    'createdAtIso': createdAtIso,
    'updatedAtIso': updatedAtIso,
    'dueAtIso': dueAtIso,
    'deleted': deleted,
  };

  factory SyncPersonalPrayer.fromJson(Map<String, dynamic> json) {
    return SyncPersonalPrayer(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      intention: '${json['intention'] ?? ''}',
      createdAtIso: '${json['createdAtIso'] ?? ''}',
      updatedAtIso: '${json['updatedAtIso'] ?? json['createdAtIso'] ?? ''}',
      dueAtIso: json['dueAtIso'] as String?,
      deleted: json['deleted'] == true,
    );
  }
}

class UserDataSnapshot {
  const UserDataSnapshot({
    this.bookmarks = const [],
    this.streakEvents = const [],
    this.prayerCompletions = const [],
    this.prayerSchedule = const [],
    this.personalPrayers = const [],
  });

  final List<SyncBookmark> bookmarks;
  final List<SyncStreakEvent> streakEvents;
  final List<SyncPrayerCompletion> prayerCompletions;
  final List<SyncPrayerScheduleSlot> prayerSchedule;
  final List<SyncPersonalPrayer> personalPrayers;
}

abstract class UserDataRemoteStore {
  Future<void> putBookmark(String uid, SyncBookmark bookmark);
  Future<void> putStreakEvent(String uid, SyncStreakEvent event);
  Future<void> putPrayerCompletion(String uid, SyncPrayerCompletion completion);
  Future<void> putPrayerScheduleSlot(String uid, SyncPrayerScheduleSlot slot);
  Future<void> putPersonalPrayer(String uid, SyncPersonalPrayer prayer);
  Future<UserDataSnapshot> pullUserData(String uid);
}

class FirestoreUserDataRemoteStore implements UserDataRemoteStore {
  FirestoreUserDataRemoteStore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> putBookmark(String uid, SyncBookmark bookmark) {
    return _userDoc(uid)
        .collection('bookmarks')
        .doc(bookmark.id)
        .set(bookmark.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> putStreakEvent(String uid, SyncStreakEvent event) {
    return _userDoc(uid)
        .collection('streaks')
        .doc(event.id)
        .set(event.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> putPrayerCompletion(
    String uid,
    SyncPrayerCompletion completion,
  ) {
    return _userDoc(uid)
        .collection('prayerCompletions')
        .doc(completion.id)
        .set(completion.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> putPrayerScheduleSlot(String uid, SyncPrayerScheduleSlot slot) {
    return _userDoc(uid)
        .collection('prayerSchedule')
        .doc(slot.id)
        .set(slot.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> putPersonalPrayer(String uid, SyncPersonalPrayer prayer) {
    return _userDoc(uid)
        .collection('prayerList')
        .doc(prayer.id)
        .set(prayer.toJson(), SetOptions(merge: true));
  }

  @override
  Future<UserDataSnapshot> pullUserData(String uid) async {
    final user = _userDoc(uid);
    final results = await Future.wait([
      user.collection('bookmarks').get(),
      user.collection('streaks').get(),
      user.collection('prayerCompletions').get(),
      user.collection('prayerSchedule').get(),
      user.collection('prayerList').get(),
    ]);
    return UserDataSnapshot(
      bookmarks: results[0].docs.map((doc) {
        return SyncBookmark.fromJson(doc.data());
      }).toList(),
      streakEvents: results[1].docs.map((doc) {
        return SyncStreakEvent.fromJson(doc.data());
      }).toList(),
      prayerCompletions: results[2].docs.map((doc) {
        return SyncPrayerCompletion.fromJson(doc.data());
      }).toList(),
      prayerSchedule: results[3].docs.map((doc) {
        return SyncPrayerScheduleSlot.fromJson(doc.data());
      }).toList(),
      personalPrayers: results[4].docs.map((doc) {
        return SyncPersonalPrayer.fromJson(doc.data());
      }).toList(),
    );
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }
}

class UserDataSyncService {
  UserDataSyncService({
    required this.db,
    required this.uid,
    required this.remote,
  });

  static const queueMetaKey = 'user_data_sync_queue_v1';

  final AppDatabase db;
  final String uid;
  final UserDataRemoteStore remote;

  Future<void> mirrorBookmarkSaved({
    required String id,
    required String title,
    required String kind,
    required String createdAtIso,
    String? body,
  }) {
    return _sendOrQueue(
      _SyncOperation(
        type: 'bookmark',
        data: SyncBookmark(
          id: id,
          title: title,
          kind: kind,
          createdAtIso: createdAtIso,
          updatedAtIso: DateTime.now().toIso8601String(),
          body: body,
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorBookmarkDeleted(String id) {
    final now = DateTime.now().toIso8601String();
    return _sendOrQueue(
      _SyncOperation(
        type: 'bookmark',
        data: SyncBookmark(
          id: id,
          title: '',
          kind: '',
          createdAtIso: now,
          updatedAtIso: now,
          deleted: true,
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorStreakCompleted({
    required String dateYmd,
    required String taskId,
    required String completedAtIso,
  }) {
    return _sendOrQueue(
      _SyncOperation(
        type: 'streak',
        data: SyncStreakEvent(
          dateYmd: dateYmd,
          taskId: taskId,
          completedAtIso: completedAtIso,
          updatedAtIso: DateTime.now().toIso8601String(),
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorStreakRemoved({
    required String dateYmd,
    required String taskId,
  }) {
    final now = DateTime.now().toIso8601String();
    return _sendOrQueue(
      _SyncOperation(
        type: 'streak',
        data: SyncStreakEvent(
          dateYmd: dateYmd,
          taskId: taskId,
          completedAtIso: now,
          updatedAtIso: now,
          deleted: true,
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorPrayerCompletion({
    required String dateYmd,
    required int slotId,
    required String completedAtIso,
  }) {
    return _sendOrQueue(
      _SyncOperation(
        type: 'prayer_completion',
        data: SyncPrayerCompletion(
          dateYmd: dateYmd,
          slotId: slotId,
          completedAtIso: completedAtIso,
          updatedAtIso: DateTime.now().toIso8601String(),
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorPrayerScheduleSlot({
    required int slotId,
    required String label,
    required String timeLocal,
    required bool isEnabled,
  }) {
    return _sendOrQueue(
      _SyncOperation(
        type: 'prayer_schedule',
        data: SyncPrayerScheduleSlot(
          slotId: slotId,
          label: label,
          timeLocal: timeLocal,
          isEnabled: isEnabled,
          updatedAtIso: DateTime.now().toIso8601String(),
        ).toJson(),
      ),
    );
  }

  Future<void> mirrorPersonalPrayer({
    required String id,
    required String name,
    required String intention,
    required String createdAtIso,
    String? updatedAtIso,
    String? dueAtIso,
  }) {
    final updatedAt = updatedAtIso ?? DateTime.now().toIso8601String();
    return _sendOrQueue(
      _SyncOperation(
        type: 'personal_prayer',
        data: SyncPersonalPrayer(
          id: id,
          name: name,
          intention: intention,
          createdAtIso: createdAtIso,
          updatedAtIso: updatedAt,
          dueAtIso: dueAtIso,
        ).toJson(),
      ),
    );
  }

  Future<void> pullRemoteChanges() async {
    final snapshot = await remote.pullUserData(uid);
    await db.transaction(() async {
      for (final bookmark in snapshot.bookmarks) {
        if (bookmark.deleted) {
          await db.savedItemsDao.removeSavedItem(bookmark.id);
          continue;
        }
        final local = await (db.select(
          db.savedItems,
        )..where((tbl) => tbl.id.equals(bookmark.id))).getSingleOrNull();
        if (_remoteWins(bookmark.updatedAtIso, local?.createdAtIso)) {
          await db.savedItemsDao.addSavedItem(
            id: bookmark.id,
            title: bookmark.title,
            kind: bookmark.kind,
            createdAtIso: bookmark.createdAtIso,
            body: bookmark.body,
          );
        }
      }

      for (final event in snapshot.streakEvents) {
        if (event.deleted) {
          await db.streakDao.removeTaskCompletion(
            dateYmd: event.dateYmd,
            taskId: event.taskId,
          );
          continue;
        }
        await db.streakDao.completeTask(
          dateYmd: event.dateYmd,
          taskId: event.taskId,
          completedAtIso: event.completedAtIso,
        );
      }

      for (final completion in snapshot.prayerCompletions) {
        if (completion.deleted) {
          continue;
        }
        await db.prayerDao.addPrayerCompletion(
          dateYmd: completion.dateYmd,
          slotId: completion.slotId,
          completedAtIso: completion.completedAtIso,
        );
      }

      for (final slot in snapshot.prayerSchedule) {
        await db.prayerDao.upsertPrayerSlot(
          slotId: slot.slotId,
          label: slot.label,
          timeLocal: slot.timeLocal,
          isEnabled: slot.isEnabled,
        );
      }

      for (final prayer in snapshot.personalPrayers) {
        if (prayer.deleted) {
          await db.personalPrayersDao.deletePersonalPrayer(prayer.id);
          continue;
        }
        final local = await (db.select(
          db.personalPrayers,
        )..where((tbl) => tbl.id.equals(prayer.id))).getSingleOrNull();
        if (_remoteWins(prayer.updatedAtIso, local?.updatedAtIso)) {
          await db.personalPrayersDao.upsertPersonalPrayer(
            id: prayer.id,
            name: prayer.name,
            intention: prayer.intention,
            createdAtIso: prayer.createdAtIso,
            updatedAtIso: prayer.updatedAtIso,
            dueAtIso: prayer.dueAtIso,
          );
        }
      }
    });
  }

  Future<void> flushQueue() async {
    final queue = await _readQueue();
    if (queue.isEmpty) {
      return;
    }
    final remaining = <_SyncOperation>[];
    for (final operation in queue) {
      try {
        await _send(operation);
      } catch (_) {
        remaining.add(operation);
      }
    }
    await _writeQueue(remaining);
  }

  Future<int> pendingQueueCount() async {
    final queue = await _readQueue();
    return queue.length;
  }

  Future<void> _sendOrQueue(_SyncOperation operation) async {
    try {
      await _send(operation);
    } catch (_) {
      final queue = await _readQueue();
      await _writeQueue([...queue, operation]);
    }
  }

  Future<void> _send(_SyncOperation operation) {
    switch (operation.type) {
      case 'bookmark':
        return remote.putBookmark(uid, SyncBookmark.fromJson(operation.data));
      case 'streak':
        return remote.putStreakEvent(
          uid,
          SyncStreakEvent.fromJson(operation.data),
        );
      case 'prayer_completion':
        return remote.putPrayerCompletion(
          uid,
          SyncPrayerCompletion.fromJson(operation.data),
        );
      case 'prayer_schedule':
        return remote.putPrayerScheduleSlot(
          uid,
          SyncPrayerScheduleSlot.fromJson(operation.data),
        );
      case 'personal_prayer':
        return remote.putPersonalPrayer(
          uid,
          SyncPersonalPrayer.fromJson(operation.data),
        );
    }
    throw StateError('Unknown sync operation: ${operation.type}');
  }

  Future<List<_SyncOperation>> _readQueue() async {
    final raw = await db.metaDao.readMeta(queueMetaKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_SyncOperation.fromJson)
        .toList(growable: false);
  }

  Future<void> _writeQueue(List<_SyncOperation> queue) {
    return db.metaDao.upsertMeta(
      queueMetaKey,
      jsonEncode(queue.map((operation) => operation.toJson()).toList()),
    );
  }
}

class _SyncOperation {
  const _SyncOperation({required this.type, required this.data});

  final String type;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => {'type': type, 'data': data};

  factory _SyncOperation.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return _SyncOperation(
      type: '${json['type'] ?? ''}',
      data: data is Map<String, dynamic> ? data : const {},
    );
  }
}

bool _remoteWins(String remoteUpdatedAtIso, String? localUpdatedAtIso) {
  if (localUpdatedAtIso == null || localUpdatedAtIso.trim().isEmpty) {
    return true;
  }
  final remote = DateTime.tryParse(remoteUpdatedAtIso);
  final local = DateTime.tryParse(localUpdatedAtIso);
  if (remote == null || local == null) {
    return true;
  }
  return !remote.isBefore(local);
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value') ?? 0;
}

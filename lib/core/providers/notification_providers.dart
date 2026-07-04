import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/daos/prayer_dao.dart';
import '../notifications/prayer_notification_service.dart';
import '../profile/profile_settings.dart';
import 'repo_providers.dart';

final prayerNotificationServiceProvider = Provider<PrayerNotificationService>(
  (ref) => PrayerNotificationService.instance,
);

final prayerNotificationBootstrapProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(dbProvider);
  final dao = PrayerDao(db);
  await dao.ensureDefaultPrayerSchedule();
  final rows = await dao.listPrayerSchedule();
  final slots = rows
      .map(
        (row) => PrayerReminderSlot(
          slotId: row.slotId,
          label: row.label,
          timeLocal: row.timeLocal,
          isEnabled: row.isEnabled,
        ),
      )
      .toList();
  final service = ref.read(prayerNotificationServiceProvider);
  await service.requestPermissions();
  await service.schedulePrayerReminders(slots);
});

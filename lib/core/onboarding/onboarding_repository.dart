import '../db/app_database.dart';
import '../notifications/prayer_notification_service.dart';
import '../profile/profile_settings.dart';
import 'onboarding_schedule.dart';

class OnboardingRepository {
  const OnboardingRepository({
    required this.db,
    required this.notificationService,
  });

  static const completedMetaKey = 'onboarding_complete_v1';

  final AppDatabase db;
  final PrayerNotificationService notificationService;

  Future<bool> isComplete() async {
    final value = await db.metaDao.readMeta(completedMetaKey);
    return value == 'true';
  }

  Future<void> complete(List<OnboardingPrayerSlot> slots) async {
    for (final slot in slots) {
      await db.prayerDao.upsertPrayerSlot(
        slotId: slot.slotId,
        label: slot.label,
        timeLocal: slot.timeLocal,
        isEnabled: slot.isEnabled,
      );
    }
    final reminderSlots = slots
        .map(
          (slot) => PrayerReminderSlot(
            slotId: slot.slotId,
            label: slot.label,
            timeLocal: slot.timeLocal,
            isEnabled: slot.isEnabled,
          ),
        )
        .toList(growable: false);
    await notificationService.requestPermissions();
    await notificationService.schedulePrayerReminders(reminderSlots);
    await db.metaDao.upsertMeta(completedMetaKey, 'true');
  }
}

import 'package:timezone/timezone.dart' as tz;

import '../../app/route_paths.dart';
import '../profile/profile_settings.dart';
import '../repos/prayer_flow_repositories.dart';
import '../strings/app_strings.dart';

class PrayerNotificationRequest {
  const PrayerNotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    required this.scheduledDate,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
  final tz.TZDateTime scheduledDate;
}

class PrayerNotificationScheduler {
  const PrayerNotificationScheduler();

  static const int notificationIdOffset = 12000;

  List<PrayerNotificationRequest> buildDailyRequests({
    required Iterable<PrayerReminderSlot> slots,
    required tz.TZDateTime now,
  }) {
    return slots.where((slot) => slot.isEnabled).map((slot) {
      final time = _parseTime(slot.timeLocal);
      final prayerId = idForSlotId(slot.slotId);
      return PrayerNotificationRequest(
        id: notificationIdForSlot(slot.slotId),
        title: AppStrings.prayerReminderTitle,
        body: AppStrings.prayerReminderBody(slot.label),
        payload: RoutePaths.prayerDetailPath(prayerId),
        scheduledDate: nextDailyOccurrence(
          location: now.location,
          now: now,
          hour: time.$1,
          minute: time.$2,
        ),
      );
    }).toList();
  }

  int notificationIdForSlot(int slotId) => notificationIdOffset + slotId;

  tz.TZDateTime nextDailyOccurrence({
    required tz.Location location,
    required tz.TZDateTime now,
    required int hour,
    required int minute,
  }) {
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  (int, int) _parseTime(String value) {
    final parts = value.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null) {
      return (6, 0);
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return (6, 0);
    }
    return (hour, minute);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:tsion_orthodox_daily_app/app/route_paths.dart';
import 'package:tsion_orthodox_daily_app/core/notifications/prayer_notification_scheduler.dart';
import 'package:tsion_orthodox_daily_app/core/profile/profile_settings.dart';

void main() {
  group('PrayerNotificationScheduler', () {
    late tz.Location location;
    late PrayerNotificationScheduler scheduler;

    setUpAll(() {
      tz_data.initializeTimeZones();
    });

    setUp(() {
      location = tz.getLocation('America/Chicago');
      scheduler = const PrayerNotificationScheduler();
    });

    test('builds daily requests for enabled slots only', () {
      final now = tz.TZDateTime(location, 2026, 1, 3, 10);
      final requests = scheduler.buildDailyRequests(
        now: now,
        slots: const [
          PrayerReminderSlot(
            slotId: 1,
            label: 'Morning',
            timeLocal: '06:00',
            isEnabled: true,
          ),
          PrayerReminderSlot(
            slotId: 2,
            label: 'Noon',
            timeLocal: '12:15',
            isEnabled: false,
          ),
          PrayerReminderSlot(
            slotId: 4,
            label: 'Night',
            timeLocal: '21:30',
            isEnabled: true,
          ),
        ],
      );

      expect(requests, hasLength(2));
      expect(requests.map((item) => item.id), [12001, 12004]);
      expect(requests.map((item) => item.payload), [
        RoutePaths.prayerDetailPath('prayer-morning'),
        RoutePaths.prayerDetailPath('prayer-night'),
      ]);
      expect(requests[0].scheduledDate, tz.TZDateTime(location, 2026, 1, 4, 6));
      expect(
        requests[1].scheduledDate,
        tz.TZDateTime(location, 2026, 1, 3, 21, 30),
      );
    });

    test('uses a safe default for malformed time values', () {
      final now = tz.TZDateTime(location, 2026, 1, 3, 5);
      final requests = scheduler.buildDailyRequests(
        now: now,
        slots: const [
          PrayerReminderSlot(
            slotId: 3,
            label: 'Evening',
            timeLocal: 'bad',
            isEnabled: true,
          ),
        ],
      );

      expect(requests.single.id, 12003);
      expect(
        requests.single.scheduledDate,
        tz.TZDateTime(location, 2026, 1, 3, 6),
      );
    });
  });
}

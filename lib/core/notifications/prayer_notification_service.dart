import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../profile/profile_settings.dart';
import '../strings/app_strings.dart';
import 'prayer_notification_scheduler.dart';

class PrayerNotificationNavigation {
  PrayerNotificationNavigation._();

  static final ValueNotifier<String?> pendingRoute = ValueNotifier<String?>(
    null,
  );

  static void setPendingRoute(String? route) {
    if (route == null || route.isEmpty) {
      return;
    }
    pendingRoute.value = route;
  }

  static String? takePendingRoute() {
    final route = pendingRoute.value;
    pendingRoute.value = null;
    return route;
  }
}

class PrayerNotificationService {
  PrayerNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    PrayerNotificationScheduler scheduler = const PrayerNotificationScheduler(),
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _scheduler = scheduler;

  static final PrayerNotificationService instance = PrayerNotificationService();

  static const _androidChannelId = 'prayer_reminders';
  static const _androidIcon = 'ic_notification';

  final FlutterLocalNotificationsPlugin _plugin;
  final PrayerNotificationScheduler _scheduler;

  Future<void> initializePlatform() async {
    await _initializeTimeZone();

    const android = AndroidInitializationSettings(_androidIcon);
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handleNotificationResponse(launchDetails!.notificationResponse);
    }
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> schedulePrayerReminders(List<PrayerReminderSlot> slots) async {
    final now = tz.TZDateTime.now(tz.local);
    final requests = _scheduler.buildDailyRequests(slots: slots, now: now);
    final details = _notificationDetails();

    for (final slot in slots) {
      await _plugin.cancel(id: _scheduler.notificationIdForSlot(slot.slotId));
    }

    for (final request in requests) {
      await _plugin.zonedSchedule(
        id: request.id,
        title: request.title,
        body: request.body,
        payload: request.payload,
        scheduledDate: request.scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      _androidChannelId,
      AppStrings.prayerReminderChannelName,
      channelDescription: AppStrings.prayerReminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  Future<void> _initializeTimeZone() async {
    tz_data.initializeTimeZones();
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));
  }

  void _handleNotificationResponse(NotificationResponse? response) {
    PrayerNotificationNavigation.setPendingRoute(response?.payload);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/daos/prayer_dao.dart';
import '../profile/profile_settings.dart';
import 'calendar_preferences_provider.dart';
import 'repo_providers.dart';

final profileSettingsRepositoryProvider = Provider<ProfileSettingsRepository>(
  (ref) =>
      ProfileSettingsRepository(prayerDao: PrayerDao(ref.watch(dbProvider))),
);

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferencesSettings>(
      AppPreferencesController.new,
    );

final prayerRemindersProvider =
    AsyncNotifierProvider<PrayerRemindersController, List<PrayerReminderSlot>>(
      PrayerRemindersController.new,
    );

final notificationCenterProvider =
    AsyncNotifierProvider<
      NotificationCenterController,
      NotificationCenterSettings
    >(NotificationCenterController.new);

class ProfileSettingsRepository {
  ProfileSettingsRepository({required PrayerDao prayerDao})
    : _prayerDao = prayerDao;

  static const _feastCalculationKey = 'feast_calculation_mode';
  static const _notificationDailyReadingsKey = 'notif_daily_readings';
  static const _notificationDailyWisdomKey = 'notif_daily_wisdom';
  static const _notificationFeastAlertsKey = 'notif_feast_alerts';
  static const _notificationPrayerRemindersKey = 'notif_prayer_reminders';
  static const _notificationGeneralKey = 'notif_general';

  final PrayerDao _prayerDao;

  Future<AppPreferencesSettings> loadAppPreferences({
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferencesSettings(
      calendarDisplayMode: calendarDisplayMode,
      feastCalculationMode: feastCalculationModeFromStorage(
        prefs.getString(_feastCalculationKey),
      ),
    );
  }

  Future<void> saveAppPreferences(AppPreferencesSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _feastCalculationKey,
      settings.feastCalculationMode.storageValue,
    );
  }

  Future<List<PrayerReminderSlot>> loadPrayerReminders() async {
    await _prayerDao.ensureDefaultPrayerSchedule();
    final rows = await _prayerDao.listPrayerSchedule();
    return rows
        .map(
          (row) => PrayerReminderSlot(
            slotId: row.slotId,
            label: row.label,
            timeLocal: row.timeLocal,
            isEnabled: row.isEnabled,
          ),
        )
        .toList();
  }

  Future<void> savePrayerReminder(PrayerReminderSlot slot) {
    return _prayerDao.upsertPrayerSlot(
      slotId: slot.slotId,
      label: slot.label,
      timeLocal: slot.timeLocal,
      isEnabled: slot.isEnabled,
    );
  }

  Future<NotificationCenterSettings> loadNotificationCenter() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationCenterSettings(
      dailyReadings: prefs.getBool(_notificationDailyReadingsKey) ?? true,
      dailyWisdom: prefs.getBool(_notificationDailyWisdomKey) ?? true,
      feastDayAlerts: prefs.getBool(_notificationFeastAlertsKey) ?? true,
      prayerReminders: prefs.getBool(_notificationPrayerRemindersKey) ?? true,
      generalAnnouncements: prefs.getBool(_notificationGeneralKey) ?? false,
    );
  }

  Future<void> saveNotificationCenter(
    NotificationCenterSettings settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationDailyReadingsKey, settings.dailyReadings);
    await prefs.setBool(_notificationDailyWisdomKey, settings.dailyWisdom);
    await prefs.setBool(_notificationFeastAlertsKey, settings.feastDayAlerts);
    await prefs.setBool(
      _notificationPrayerRemindersKey,
      settings.prayerReminders,
    );
    await prefs.setBool(_notificationGeneralKey, settings.generalAnnouncements);
  }
}

class AppPreferencesController extends AsyncNotifier<AppPreferencesSettings> {
  @override
  Future<AppPreferencesSettings> build() {
    final calendarMode = ref.watch(calendarDisplayModeProvider);
    return ref
        .read(profileSettingsRepositoryProvider)
        .loadAppPreferences(calendarDisplayMode: calendarMode);
  }

  Future<void> save(AppPreferencesSettings settings) async {
    await ref
        .read(profileSettingsRepositoryProvider)
        .saveAppPreferences(settings);
    ref
        .read(calendarDisplayModeProvider.notifier)
        .setMode(settings.calendarDisplayMode);
    state = AsyncData(settings);
  }
}

class PrayerRemindersController
    extends AsyncNotifier<List<PrayerReminderSlot>> {
  @override
  Future<List<PrayerReminderSlot>> build() {
    return ref.read(profileSettingsRepositoryProvider).loadPrayerReminders();
  }

  Future<void> saveSlot(PrayerReminderSlot slot) async {
    await ref.read(profileSettingsRepositoryProvider).savePrayerReminder(slot);
    final current = state.valueOrNull ?? const <PrayerReminderSlot>[];
    final updated = current
        .map((item) => item.slotId == slot.slotId ? slot : item)
        .toList();
    state = AsyncData(updated);
  }
}

class NotificationCenterController
    extends AsyncNotifier<NotificationCenterSettings> {
  @override
  Future<NotificationCenterSettings> build() {
    return ref.read(profileSettingsRepositoryProvider).loadNotificationCenter();
  }

  Future<void> save(NotificationCenterSettings settings) async {
    await ref
        .read(profileSettingsRepositoryProvider)
        .saveNotificationCenter(settings);
    state = AsyncData(settings);
  }
}

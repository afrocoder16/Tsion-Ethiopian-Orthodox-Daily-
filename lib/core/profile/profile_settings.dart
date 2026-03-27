import 'package:flutter/material.dart';

import '../models/calendar_display_mode.dart';

enum FeastCalculationMode { ethiopian, gregorian }

extension FeastCalculationModeX on FeastCalculationMode {
  String get storageValue {
    switch (this) {
      case FeastCalculationMode.ethiopian:
        return 'ethiopian';
      case FeastCalculationMode.gregorian:
        return 'gregorian';
    }
  }

  String get label {
    switch (this) {
      case FeastCalculationMode.ethiopian:
        return 'Ethiopian';
      case FeastCalculationMode.gregorian:
        return 'Gregorian';
    }
  }
}

FeastCalculationMode feastCalculationModeFromStorage(String? value) {
  if (value == FeastCalculationMode.gregorian.storageValue) {
    return FeastCalculationMode.gregorian;
  }
  return FeastCalculationMode.ethiopian;
}

class AppPreferencesSettings {
  const AppPreferencesSettings({
    required this.calendarDisplayMode,
    required this.feastCalculationMode,
  });

  final CalendarDisplayMode calendarDisplayMode;
  final FeastCalculationMode feastCalculationMode;

  AppPreferencesSettings copyWith({
    CalendarDisplayMode? calendarDisplayMode,
    FeastCalculationMode? feastCalculationMode,
  }) {
    return AppPreferencesSettings(
      calendarDisplayMode: calendarDisplayMode ?? this.calendarDisplayMode,
      feastCalculationMode: feastCalculationMode ?? this.feastCalculationMode,
    );
  }
}

class PrayerReminderSlot {
  const PrayerReminderSlot({
    required this.slotId,
    required this.label,
    required this.timeLocal,
    required this.isEnabled,
  });

  final int slotId;
  final String label;
  final String timeLocal;
  final bool isEnabled;

  PrayerReminderSlot copyWith({
    int? slotId,
    String? label,
    String? timeLocal,
    bool? isEnabled,
  }) {
    return PrayerReminderSlot(
      slotId: slotId ?? this.slotId,
      label: label ?? this.label,
      timeLocal: timeLocal ?? this.timeLocal,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  TimeOfDay get timeOfDay {
    final parts = timeLocal.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 6 : 6;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class NotificationCenterSettings {
  const NotificationCenterSettings({
    required this.dailyReadings,
    required this.dailyWisdom,
    required this.feastDayAlerts,
    required this.prayerReminders,
    required this.generalAnnouncements,
  });

  final bool dailyReadings;
  final bool dailyWisdom;
  final bool feastDayAlerts;
  final bool prayerReminders;
  final bool generalAnnouncements;

  NotificationCenterSettings copyWith({
    bool? dailyReadings,
    bool? dailyWisdom,
    bool? feastDayAlerts,
    bool? prayerReminders,
    bool? generalAnnouncements,
  }) {
    return NotificationCenterSettings(
      dailyReadings: dailyReadings ?? this.dailyReadings,
      dailyWisdom: dailyWisdom ?? this.dailyWisdom,
      feastDayAlerts: feastDayAlerts ?? this.feastDayAlerts,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      generalAnnouncements: generalAnnouncements ?? this.generalAnnouncements,
    );
  }
}

enum CalendarDisplayMode { ethiopian, gregorian }

extension CalendarDisplayModeX on CalendarDisplayMode {
  String get storageValue {
    switch (this) {
      case CalendarDisplayMode.ethiopian:
        return 'ethiopian';
      case CalendarDisplayMode.gregorian:
        return 'gregorian';
    }
  }
}

CalendarDisplayMode calendarDisplayModeFromStorage(String? value) {
  if (value == CalendarDisplayMode.gregorian.storageValue) {
    return CalendarDisplayMode.gregorian;
  }
  return CalendarDisplayMode.ethiopian;
}

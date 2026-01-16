class CalendarDayDetailState {
  const CalendarDayDetailState({
    required this.dateKey,
    required this.ethiopianDate,
    required this.gregorianDate,
    required this.bahireTitle,
    required this.bahireDescription,
    required this.bahireTags,
    required this.observances,
    required this.links,
  });

  final String dateKey;
  final String ethiopianDate;
  final String gregorianDate;
  final String bahireTitle;
  final String bahireDescription;
  final List<String> bahireTags;
  final List<CalendarObservance> observances;
  final List<CalendarLink> links;
}

class CalendarObservance {
  const CalendarObservance({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class CalendarLink {
  const CalendarLink({
    required this.label,
    required this.type,
  });

  final String label;
  final CalendarLinkType type;
}

enum CalendarLinkType { readings, saint, prayers }

abstract class CalendarDayDetailRepository {
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey);
}

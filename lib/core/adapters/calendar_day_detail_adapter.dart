import '../repos/calendar_day_detail_repositories.dart';

class CalendarDayDetailAdapter {
  CalendarDayDetailAdapter(this.state);

  final CalendarDayDetailState state;

  String get ethiopianDate => _safeText(state.ethiopianDate, state.dateKey);
  String get gregorianDate => _safeText(state.gregorianDate, '-');
  String get bahireTitle => _safeText(state.bahireTitle, 'Bahire Hasab');
  String get bahireDescription =>
      _safeText(state.bahireDescription, 'Daily signals for this day.');
  List<String> get bahireTags => state.bahireTags;
  List<CalendarObservance> get observances => state.observances;
  List<CalendarLink> get links => state.links;
}

String _safeText(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

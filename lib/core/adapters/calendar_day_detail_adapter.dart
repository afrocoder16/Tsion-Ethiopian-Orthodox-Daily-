import '../calendar/calendar_engine_models.dart';
import '../repos/calendar_day_detail_repositories.dart';

class CalendarDayDetailAdapter {
  CalendarDayDetailAdapter(this.state);

  final CalendarDayDetailState state;

  String get ethiopianDate => _safeText(state.ethiopianDate, state.dateKey);
  String get gregorianDate => _safeText(state.gregorianDate, '-');
  String get weekday => _safeText(state.weekday, '-');
  String get bahireTitle => _safeText(state.bahireTitle, 'Bahire Hasab');
  String get bahireDescription =>
      _safeText(state.bahireDescription, 'Daily signals for this day.');
  List<BahireStatChipView> get bahireStats => [
    BahireStatChipView(
      label: 'Evangelist',
      value: state.bahireHasabStats.evangelist,
    ),
    BahireStatChipView(
      label: 'Amete Alem',
      value: state.bahireHasabStats.ameteAlem.toString(),
    ),
    BahireStatChipView(
      label: 'Abekte',
      value: state.bahireHasabStats.abekte.toString(),
    ),
    BahireStatChipView(
      label: 'Metkih',
      value: state.bahireHasabStats.metkih.toString(),
    ),
    BahireStatChipView(
      label: 'Wenber',
      value: state.bahireHasabStats.wenber.toString(),
    ),
    BahireStatChipView(
      label: 'Meskerem 1',
      value: state.bahireHasabStats.meskeremOneWeekday,
    ),
  ];
  List<CalendarObservance> get observances => state.observances;
  List<Celebration> get celebrations => state.celebrations;
  List<SaintSummary> get saints => state.saints;
}

class BahireStatChipView {
  const BahireStatChipView({required this.label, required this.value});

  final String label;
  final String value;
}

String _safeText(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

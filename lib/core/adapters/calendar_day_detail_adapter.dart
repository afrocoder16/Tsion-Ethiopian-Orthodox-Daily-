import '../calendar/calendar_engine_models.dart';
import '../repos/calendar_day_detail_repositories.dart';

class CalendarDayDetailAdapter {
  CalendarDayDetailAdapter(this.state);

  final CalendarDayDetailState state;

  String get ethiopianDate => _safeText(state.ethiopianDate, state.dateKey);
  String get gregorianDate => _safeText(state.gregorianDate, '-');
  String get weekday => _safeText(state.weekday, '-');
  String get evangelist =>
      _safeText(state.bahireHasabStats.evangelist, state.dayObservance.evangelistKey);
  List<CalendarObservance> get observances => state.observances;
  List<CelebrationViewItem> get celebrations {
    final items = <CelebrationViewItem>[
      ...state.celebrations.map(
        (item) => CelebrationViewItem(title: item.title, subtitle: item.subtitle),
      ),
      ...state.lents.map(
        (item) => CelebrationViewItem(title: item.name, subtitle: 'Lent'),
      ),
    ];
    final deduped = <String, CelebrationViewItem>{};
    for (final item in items) {
      final key = item.title.trim().toLowerCase();
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = item;
        continue;
      }
      if (item.subtitle.toLowerCase() == 'annual feast' &&
          existing.subtitle.toLowerCase() != 'annual feast') {
        deduped[key] = item;
      }
    }
    return deduped.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }
  List<SaintSummary> get saints => state.saints;
}

class CelebrationViewItem {
  const CelebrationViewItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

String _safeText(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

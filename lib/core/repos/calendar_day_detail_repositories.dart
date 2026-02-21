import '../calendar/calendar_engine_models.dart';

class CalendarDayDetailState {
  const CalendarDayDetailState({
    required this.dateKey,
    required this.ethiopianDate,
    required this.gregorianDate,
    required this.weekday,
    required this.dayObservance,
    required this.bahireTitle,
    required this.bahireDescription,
    required this.bahireHasabStats,
    required this.observances,
    required this.celebrations,
    required this.saints,
  });

  final String dateKey;
  final String ethiopianDate;
  final String gregorianDate;
  final String weekday;
  final DayObservance dayObservance;
  final String bahireTitle;
  final String bahireDescription;
  final BahireHasabStats bahireHasabStats;
  final List<CalendarObservance> observances;
  final List<Celebration> celebrations;
  final List<SaintSummary> saints;
}

class CalendarObservance {
  const CalendarObservance({required this.label, required this.value});

  final String label;
  final String value;
}

abstract class CalendarDayDetailRepository {
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey);
}

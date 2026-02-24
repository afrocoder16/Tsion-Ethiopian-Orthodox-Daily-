import '../calendar/calendar_engine_models.dart';

abstract class CelebrationsRepository {
  Future<List<Celebration>> fetchCelebrationsForDay({
    required DayObservance dayObservance,
  });

  Future<List<LentSummary>> fetchLentsForDay({
    required DayObservance dayObservance,
  });
}

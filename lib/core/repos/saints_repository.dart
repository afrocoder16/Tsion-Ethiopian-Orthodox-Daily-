import '../calendar/calendar_engine_models.dart';

abstract class SaintsRepository {
  Future<List<SaintSummary>> fetchSaintsForDate(EthDate ethDate);
}

import '../../calendar/calendar_engine.dart';
import '../../calendar/calendar_engine_models.dart';
import '../celebrations_repository.dart';

class DbCelebrationsRepository implements CelebrationsRepository {
  DbCelebrationsRepository({required this.engine});

  final CalendarEngine engine;
  final Map<int, List<Celebration>> _movableCache = {};

  @override
  Future<List<Celebration>> fetchCelebrationsForDay({
    required DayObservance dayObservance,
  }) async {
    final eth = dayObservance.ethDate;
    final result = <Celebration>[];

    result.addAll(_monthlyRecurringCelebrations(eth));

    final movable = _movableCache.putIfAbsent(
      eth.year,
      () => engine.getMovableCelebrationsForYear(eth.year),
    );
    result.addAll(movable.where((item) => item.ethDateKey == eth.key));

    for (final feast in dayObservance.feasts) {
      result.add(
        Celebration(
          id: 'feast_${feast.id}_${eth.key}',
          title: feast.nameKey,
          subtitle: feast.kind == 'MOVABLE' ? 'Movable feast' : 'Fixed feast',
          ethDateKey: eth.key,
        ),
      );
    }

    final season = dayObservance.fastStatus.seasonNameKey;
    if (season != null && season.trim().isNotEmpty) {
      result.add(
        Celebration(
          id: 'season_${dayObservance.fastStatus.seasonId ?? season}_${eth.key}',
          title: season,
          subtitle: 'Fast season',
          ethDateKey: eth.key,
        ),
      );
    }

    final deduped = <String, Celebration>{};
    for (final item in result) {
      final key = '${item.title.toLowerCase()}|${item.subtitle.toLowerCase()}';
      deduped[key] = item;
    }
    return deduped.values.toList();
  }

  List<Celebration> _monthlyRecurringCelebrations(EthDate eth) {
    final list = <Celebration>[];
    void add(int day, String title, String subtitle) {
      if (eth.day != day) {
        return;
      }
      list.add(
        Celebration(
          id: 'fixed_${day}_$title',
          title: title,
          subtitle: subtitle,
          ethDateKey: eth.key,
        ),
      );
    }

    add(7, 'Trinity', 'Monthly recurring feast');
    add(12, 'Archangel Michael', 'Monthly recurring feast');
    add(16, 'Kidane Mihret', 'Monthly recurring feast');
    add(21, 'St Mary', 'Monthly recurring feast');
    add(27, 'Medhane Alem', 'Monthly recurring feast');
    add(29, 'Birth of Christ', 'Monthly recurring feast');
    return list;
  }
}

import '../../calendar/calendar_engine.dart';
import '../../calendar/calendar_observance_store.dart';
import '../../db/app_database.dart';
import '../calendar_day_detail_repositories.dart';

class DbCalendarDayDetailRepository implements CalendarDayDetailRepository {
  DbCalendarDayDetailRepository({required this.db, required this.engine});

  final AppDatabase db;
  final CalendarEngine engine;

  @override
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey) async {
    final target = _parseDateKey(dateKey);
    final store = CalendarObservanceStore(db: db, engine: engine);
    final day = await store.getByGregorianDate(target);
    final anchors = engine.getAnchorsForYear(day.ethDate.year);

    final observances = <CalendarObservance>[];
    for (final feast in day.feasts) {
      observances.add(CalendarObservance(label: 'Feast', value: feast.nameKey));
    }
    if (day.fastStatus.isFastingDay) {
      observances.add(
        CalendarObservance(
          label: 'Fast',
          value: day.fastStatus.seasonNameKey ?? 'Fasting day',
        ),
      );
    }
    if (observances.isEmpty) {
      observances.add(
        const CalendarObservance(label: 'Day', value: 'Regular day'),
      );
    }

    return CalendarDayDetailState(
      dateKey: day.gregorianDateYmd,
      ethiopianDate: day.ethDate.key,
      gregorianDate: day.gregorianDateYmd,
      bahireTitle: 'Bahire Hasab',
      bahireDescription:
          'Computed from Ethiopian calendar anchors and fasting rules.',
      bahireTags: [
        'Evangelist: ${anchors.evangelistName}',
        'Nenewe: ${anchors.nenewe.key}',
        'Easter: ${anchors.easter.key}',
        'Pentecost: ${anchors.pentecost.key}',
      ],
      observances: observances,
      links: const [
        CalendarLink(label: 'Readings', type: CalendarLinkType.readings),
        CalendarLink(label: 'Saint', type: CalendarLinkType.saint),
        CalendarLink(label: 'Prayers', type: CalendarLinkType.prayers),
      ],
    );
  }

  DateTime _parseDateKey(String dateKey) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateKey);
    if (match == null) {
      return DateTime.now();
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return DateTime(year, month, day, 12);
  }
}

import '../calendar_day_detail_repositories.dart';

class FakeCalendarDayDetailRepository implements CalendarDayDetailRepository {
  @override
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey) {
    return Future.value(
      CalendarDayDetailState(
        dateKey: dateKey,
        ethiopianDate: dateKey,
        gregorianDate: 'December 13',
        bahireTitle: 'Bahire Hasab',
        bahireDescription:
            'Interpreted values for the day in the church calendar.',
        bahireTags: const [
          'Evangelist: Matthew',
          'Season: Advent',
          'Fast: Wednesday',
        ],
        observances: const [
          CalendarObservance(label: 'Saint', value: 'St. Lucia'),
          CalendarObservance(label: 'Fast', value: 'Wednesday Fast'),
        ],
        links: const [
          CalendarLink(label: 'Readings', type: CalendarLinkType.readings),
          CalendarLink(label: 'Saint', type: CalendarLinkType.saint),
          CalendarLink(label: 'Prayers', type: CalendarLinkType.prayers),
        ],
      ),
    );
  }
}

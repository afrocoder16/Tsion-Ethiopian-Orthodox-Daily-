import '../../calendar/calendar_engine_models.dart';
import '../calendar_day_detail_repositories.dart';

class FakeCalendarDayDetailRepository implements CalendarDayDetailRepository {
  @override
  Future<CalendarDayDetailState> fetchDayDetail(String dateKey) {
    return Future.value(
      CalendarDayDetailState(
        dateKey: dateKey,
        ethiopianDate: dateKey,
        gregorianDate: 'December 13',
        weekday: 'Thursday',
        dayObservance: const DayObservance(
          gregorianDateYmd: '2026-02-20',
          ethDate: EthDate(year: 2018, month: 6, day: 13),
          weekdayKey: 'Thursday',
          evangelistKey: 'Matthew',
          fastStatus: FastStatusResult(
            isFastingDay: true,
            reasons: ['FAST_SEASON', 'WED_FRI'],
            seasonId: 'GREAT_LENT',
            seasonNameKey: 'Great Lent',
          ),
          seasonProgress: null,
          feasts: [],
          dailyReadings: DailyReadingsData(
            morning: [],
            liturgy: [],
            evening: [],
            isLoaded: false,
          ),
          saintsPreview: [],
          movableSignals: {},
          engineVersion: '1.0.0',
          rulesetVersion: '1.0.0',
        ),
        bahireTitle: 'Bahire Hasab',
        bahireDescription: 'Orthodox day observance details.',
        bahireHasabStats: const BahireHasabStats(
          evangelist: 'Matthew',
          ameteAlem: 7518,
          abekte: 12,
          metkih: 18,
          wenber: 12,
          meskeremOneWeekday: 'Wednesday',
        ),
        observances: const [
          CalendarObservance(label: 'Fasting today', value: 'Yes'),
          CalendarObservance(label: 'Type', value: 'Great Lent'),
        ],
        celebrations: const [
          Celebration(
            id: 'c1',
            title: 'Archangel Michael',
            subtitle: 'Monthly recurring feast',
            ethDateKey: '2018-06-12',
          ),
        ],
        saints: const [
          SaintSummary(
            id: 's1',
            name: 'St Michael',
            snippet: 'Protector and intercessor.',
          ),
        ],
        lents: const [
          LentSummary(
            id: 'abiy_tsom_hudadi',
            name: 'Great Lent (Hudadi or Abiye Tsom)',
            status: 'Active today',
          ),
        ],
      ),
    );
  }
}

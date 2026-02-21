import '../../db/app_database.dart';
import '../../db/daos/streak_events_dao.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbTodayRepository implements TodayRepository {
  DbTodayRepository(this.db);

  final AppDatabase db;

  @override
  Future<TodayScreenState> fetchTodayScreen() async {
    final todayYmd = _formatYmd(DateTime.now());
    var status = const <StreakEventStatus>[];
    try {
      status = await StreakEventsDao(db).getStreakStatusForDate(todayYmd);
    } catch (_) {
      // Older local DBs may not have streak tables yet. Keep screen usable.
      status = const <StreakEventStatus>[];
    }
    final totalTasks = status.length;
    final completedTasks = status.where((item) => item.completed).length;
    final streakText = totalTasks == 0
        ? 'No streak tasks yet'
        : 'Streak: $completedTasks/$totalTasks tasks completed';

    final state = TodayScreenState(
      header: const ui.TodayHeader(
        title: 'TODAY',
        greeting: 'Bless you',
        dateText: 'Monday - January 12',
        calendarLabel: 'Julian | Ethiopian',
      ),
      headerActions: const [
        ui.HeaderAction(iconKey: 'audio'),
        ui.HeaderAction(iconKey: 'bookmark'),
        ui.HeaderAction(iconKey: 'streak'),
        ui.HeaderAction(iconKey: 'info'),
        ui.HeaderAction(iconKey: 'calendar'),
      ],
      verseCard: const ui.VerseCard(
        id: 'verse-of-the-day',
        title: 'Verse of the Day',
        reference: 'John 11:25',
        body:
            'Jesus said to her, "I am the resurrection and the life. Whoever '
            'believes in me, though he die, yet shall he live."',
      ),
      verseStats: const [
        ui.VerseActionStat(iconKey: 'info', label: '124'),
        ui.VerseActionStat(iconKey: 'bookmark', label: '38'),
        ui.VerseActionStat(iconKey: 'share', label: '12'),
      ],
      audioCard: const ui.AudioCard(
        id: 'today-audio-reading',
        title: 'Hear Today\'s Word',
        subtitle: 'Today\'s Reading',
        durationText: '9:24 min',
      ),
      memoryCue: ui.MemoryCue(text: streakText),
      orthodoxDailyHeader: const ui.SectionHeader(
        title: 'ORTHODOX DAILY',
        showSeeAll: true,
      ),
      orthodoxDailyItems: const [
        ui.TodayCarouselItem(
          id: 'today-carousel-midday-prayer',
          title: 'Midday Prayer',
          subtitle: 'Short guided prayer',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-daily-readings',
          title: 'Daily Readings',
          subtitle: 'Lectionary selections',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-feasts-fasts',
          title: 'Feasts & Fasts',
          subtitle: 'Today in the calendar',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-todays-saint',
          title: 'Today\'s Saint',
          subtitle: 'Life and remembrance',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-daily-tip',
          title: 'Daily Tip',
          subtitle: 'Small step for today',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-ask',
          title: 'Ask a Question',
          subtitle: 'Learn the faith',
        ),
      ],
      studyWorshipHeader: const ui.SectionHeader(title: 'STUDY & WORSHIP'),
      studyWorshipItems: const [
        ui.TodayCarouselItem(
          id: 'today-carousel-mezmur',
          title: 'Mezmur',
          subtitle: 'Chants and hymns',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-light-candle',
          title: 'Light a Candle',
          subtitle: 'Pray for me',
        ),
        ui.TodayCarouselItem(
          id: 'today-carousel-find-church',
          title: 'Find Your Church',
          subtitle: 'Nearby parishes',
        ),
      ],
    );
    assert(() {
      assertValidTodayScreen(state);
      return true;
    }());
    return state;
  }
}

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

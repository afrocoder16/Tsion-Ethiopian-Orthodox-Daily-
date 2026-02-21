import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeTodayRepository implements TodayRepository {
  @override
  Future<TodayScreenState> fetchTodayScreen() {
    final state = TodayScreenState(
      header: const TodayHeader(
        title: 'TODAY',
        greeting: 'Bless you',
        dateText: 'Monday - January 12',
        calendarLabel: 'Julian | Ethiopian',
      ),
      headerActions: const [
        HeaderAction(iconKey: 'audio'),
        HeaderAction(iconKey: 'bookmark'),
        HeaderAction(iconKey: 'streak'),
        HeaderAction(iconKey: 'info'),
        HeaderAction(iconKey: 'calendar'),
      ],
      verseCard: const VerseCard(
        id: 'verse-of-the-day',
        title: 'Verse of the Day',
        reference: 'John 11:25',
        body:
            'Jesus said to her, "I am the resurrection and the life. Whoever '
            'believes in me, though he die, yet shall he live."',
      ),
      verseStats: const [
        VerseActionStat(iconKey: 'info', label: '124'),
        VerseActionStat(iconKey: 'bookmark', label: '38'),
        VerseActionStat(iconKey: 'share', label: '12'),
      ],
      audioCard: const AudioCard(
        id: 'today-audio-reading',
        title: 'Hear Today\'s Word',
        subtitle: 'Today\'s Reading',
        durationText: '9:24 min',
      ),
      memoryCue: const MemoryCue(text: 'Continue Reading'),
      orthodoxDailyHeader: const SectionHeader(
        title: 'ORTHODOX DAILY',
        showSeeAll: true,
      ),
      orthodoxDailyItems: const [
        TodayCarouselItem(
          id: 'today-carousel-midday-prayer',
          title: 'Midday Prayer',
          subtitle: 'Short guided prayer',
        ),
        TodayCarouselItem(
          id: 'today-carousel-daily-readings',
          title: 'Daily Readings',
          subtitle: 'Lectionary selections',
        ),
        TodayCarouselItem(
          id: 'today-carousel-feasts-fasts',
          title: 'Feasts & Fasts',
          subtitle: 'Today in the calendar',
        ),
        TodayCarouselItem(
          id: 'today-carousel-todays-saint',
          title: 'Today\'s Saint',
          subtitle: 'Life and remembrance',
        ),
        TodayCarouselItem(
          id: 'today-carousel-daily-tip',
          title: 'Daily Tip',
          subtitle: 'Small step for today',
        ),
        TodayCarouselItem(
          id: 'today-carousel-ask',
          title: 'Ask a Question',
          subtitle: 'Learn the faith',
        ),
      ],
      studyWorshipHeader: const SectionHeader(title: 'STUDY & WORSHIP'),
      studyWorshipItems: const [
        TodayCarouselItem(
          id: 'today-carousel-mezmur',
          title: 'Mezmur',
          subtitle: 'Chants and hymns',
        ),
        TodayCarouselItem(
          id: 'today-carousel-light-candle',
          title: 'Light a Candle',
          subtitle: 'Pray for me',
        ),
        TodayCarouselItem(
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
    return Future.value(state);
  }
}

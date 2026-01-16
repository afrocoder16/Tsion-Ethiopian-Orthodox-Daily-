import 'screen_states.dart';

abstract class TodayRepository {
  Future<TodayScreenState> fetchTodayScreen();
}

abstract class BooksRepository {
  Future<BooksScreenState> fetchBooksScreen();
}

abstract class PrayersRepository {
  Future<PrayersScreenState> fetchPrayersScreen();
}

abstract class CalendarRepository {
  Future<CalendarScreenState> fetchCalendarScreen();
}

abstract class ExploreRepository {
  Future<ExploreScreenState> fetchExploreScreen();
}

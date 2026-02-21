import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeBooksRepository implements BooksRepository {
  @override
  Future<BooksScreenState> fetchBooksScreen() {
    final state = BooksScreenState(
      readingStreakBadge: const ReadingStreakBadge(
        label: '7-day reading streak',
        compact: true,
      ),
      searchBar: const SearchBar(placeholder: 'Search by title'),
      filters: const [
        BooksFilterOption(text: 'All', value: 'all'),
        BooksFilterOption(text: 'Bible', value: 'bible'),
        BooksFilterOption(text: 'Saints', value: 'saints'),
        BooksFilterOption(text: 'Prayers', value: 'prayers'),
        BooksFilterOption(text: 'Teachings', value: 'teachings'),
        BooksFilterOption(text: 'History', value: 'history'),
      ],
      filterSelection: const FilterSelection(selected: 'all'),
      continueReadingHeader: const SectionHeader(
        title: 'Continue Reading',
        subtitle: 'Continue where you left off',
      ),
      continueReadingItems: const [
        BookItem(
          id: 'book-psalm-23',
          title: 'Psalm 23',
          subtitle: 'Last chapter: Verse 4',
        ),
        BookItem(
          id: 'book-gospel-matthew',
          title: 'Gospel of Matthew',
          subtitle: 'Last chapter: 5',
        ),
        BookItem(
          id: 'book-life-st-mary',
          title: 'Life of St. Mary',
          subtitle: 'Last chapter: 2',
        ),
      ],
      continueReadingAction: const ContinueReadingAction(
        label: 'Resume',
        progressText: 'Last chapter: Verse 4',
      ),
      saintsHeader: const SectionHeader(title: 'Saints', showSeeAll: true),
      patronSaint: const PatronSaintCard(
        id: 'patron-saint-athon',
        label: 'Your Patron Saint',
        name: 'Athon',
      ),
      patronSaintProfile: const PatronSaintProfile(
        title: 'Saint Athon',
        feastDayLabel: 'Feast Day - January 7',
        summary:
            'The prophet who prepared the way for Christ through repentance and truth.',
        tags: ['Humility', 'Repentance', 'Truthfulness'],
        changeTitle: 'Change Patron Saint',
        changeSubtitle: 'Select your guardian saint',
        reminderTitle: 'Remind me on feast day',
        lifeTitle: 'LIFE',
        lifeReadTime: '1 min read',
        lifeBody:
            'Saint John the Baptist and Forerunner is the last and greatest of the prophets, chosen by God to prepare hearts for the coming of Christ.',
        hymnTitle: 'HYMN OF PRAISE',
        hymnReadTime: '1 min read',
        hymnBody:
            'O glorious Prophet John, voice crying in the wilderness, prepare our hearts in repentance, that we may welcome the Light of Christ.',
      ),
      saintsShelf: const [
        BookItem(id: 'book-synaxarium', title: 'Synaxarium'),
        BookItem(id: 'book-lives-of-saints', title: 'Lives of Saints'),
        BookItem(id: 'book-daily-saint', title: 'Daily Saint'),
      ],
      libraryHeader: const SectionHeader(title: 'LIBRARY'),
      bibleShelf: const [
        BookItem(id: 'book-bible', title: 'Bible'),
        BookItem(id: 'book-audio-bible', title: 'Audio Bible'),
        BookItem(id: 'book-reading-plan', title: 'Reading Plan'),
      ],
      orthodoxBooksHeader: const SectionHeader(title: 'ORTHODOX BOOKS'),
      orthodoxBooks: const [
        BookItem(id: 'book-divine-liturgy', title: 'The Divine Liturgy'),
        BookItem(id: 'book-ladder', title: 'The Ladder'),
        BookItem(id: 'book-on-prayer', title: 'On Prayer'),
        BookItem(
          id: 'book-desert-fathers',
          title: 'Sayings of the Desert Fathers',
        ),
        BookItem(id: 'book-philokalia', title: 'The Philokalia'),
        BookItem(id: 'book-lives-saints', title: 'Lives of the Saints'),
      ],
    );
    assert(() {
      assertValidBooksScreen(state);
      return true;
    }());
    return Future.value(state);
  }
}


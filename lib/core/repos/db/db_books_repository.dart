import '../../db/app_database.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbBooksRepository implements BooksRepository {
  DbBooksRepository(this.db);

  final AppDatabase db;

  @override
  Future<BooksScreenState> fetchBooksScreen() async {
    const defaultContinueReadingItems = [
      ui.BookItem(
        id: 'book-psalm-23',
        title: 'Psalm 23',
        subtitle: 'Last chapter: Verse 4',
      ),
      ui.BookItem(
        id: 'book-gospel-matthew',
        title: 'Gospel of Matthew',
        subtitle: 'Last chapter: 5',
      ),
      ui.BookItem(
        id: 'book-life-st-mary',
        title: 'Life of St. Mary',
        subtitle: 'Last chapter: 2',
      ),
    ];

    final progressRow = await db.readingProgressDao
        .getReadingProgress(defaultContinueReadingItems[0].id);
    final progressText = progressRow?.progressText;

    final updatedContinueReading = progressRow == null
        ? <ui.BookItem>[]
        : [
            ui.BookItem(
              id: defaultContinueReadingItems[0].id,
              title: defaultContinueReadingItems[0].title,
              subtitle: progressRow.progressText,
            ),
          ];

    final state = BooksScreenState(
      readingStreakBadge: const ui.ReadingStreakBadge(
        label: '7-day reading streak',
        compact: true,
      ),
      searchBar: const ui.SearchBar(placeholder: 'Search by title'),
      filters: const [
        ui.BooksFilterOption(text: 'All', value: 'all'),
        ui.BooksFilterOption(text: 'Bible', value: 'bible'),
        ui.BooksFilterOption(text: 'Saints', value: 'saints'),
        ui.BooksFilterOption(text: 'Prayers', value: 'prayers'),
        ui.BooksFilterOption(text: 'Teachings', value: 'teachings'),
        ui.BooksFilterOption(text: 'History', value: 'history'),
      ],
      filterSelection: const ui.FilterSelection(selected: 'all'),
      continueReadingHeader: const ui.SectionHeader(
        title: 'Continue Reading',
        subtitle: 'Continue where you left off',
      ),
      continueReadingItems: updatedContinueReading,
      continueReadingAction: ui.ContinueReadingAction(
        label: 'Resume',
        progressText: progressText,
      ),
      saintsHeader: const ui.SectionHeader(
        title: 'Saints',
        showSeeAll: true,
      ),
      patronSaint: const ui.PatronSaintCard(
        id: 'patron-saint-athon',
        label: 'Your Patron Saint',
        name: 'Athon',
      ),
      saintsShelf: const [
        ui.BookItem(id: 'book-synaxarium', title: 'Synaxarium'),
        ui.BookItem(id: 'book-lives-of-saints', title: 'Lives of Saints'),
        ui.BookItem(id: 'book-daily-saint', title: 'Daily Saint'),
      ],
      libraryHeader: const ui.SectionHeader(title: 'LIBRARY'),
      bibleShelf: const [
        ui.BookItem(id: 'book-bible', title: 'Bible'),
        ui.BookItem(id: 'book-audio-bible', title: 'Audio Bible'),
        ui.BookItem(id: 'book-reading-plan', title: 'Reading Plan'),
      ],
      orthodoxBooksHeader: const ui.SectionHeader(title: 'ORTHODOX BOOKS'),
      orthodoxBooks: const [
        ui.BookItem(id: 'book-divine-liturgy', title: 'The Divine Liturgy'),
        ui.BookItem(id: 'book-ladder', title: 'The Ladder'),
        ui.BookItem(id: 'book-on-prayer', title: 'On Prayer'),
        ui.BookItem(
          id: 'book-desert-fathers',
          title: 'Sayings of the Desert Fathers',
        ),
        ui.BookItem(id: 'book-philokalia', title: 'The Philokalia'),
        ui.BookItem(id: 'book-lives-saints', title: 'Lives of the Saints'),
      ],
    );
    assert(() {
      assertValidBooksScreen(state);
      return true;
    }());
    return state;
  }
}

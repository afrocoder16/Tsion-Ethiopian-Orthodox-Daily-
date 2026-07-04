import '../../db/app_database.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../../strings/app_strings.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbBooksRepository implements BooksRepository {
  DbBooksRepository(this.db);

  final AppDatabase db;

  @override
  Future<BooksScreenState> fetchBooksScreen() async {
    String? progressText;
    List<ui.BookItem> updatedContinueReading = <ui.BookItem>[];
    try {
      final progressRows = await db.readingProgressDao
          .fetchRecentReadingProgress(limit: 5);
      final filteredRows = _filterContinueReadingRows(progressRows);
      progressText = filteredRows.isEmpty
          ? null
          : filteredRows.first.progressText;
      updatedContinueReading = filteredRows
          .map(
            (row) => ui.BookItem(
              id: row.bookId,
              title: _displayTitleForBookId(row.bookId),
              subtitle: row.progressText,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      // Keep Books screen available even if local DB schema lags behind.
      progressText = null;
      updatedContinueReading = <ui.BookItem>[];
    }

    final state = BooksScreenState(
      readingStreakBadge: const ui.ReadingStreakBadge(
        label: '7-day reading streak',
        compact: true,
      ),
      searchBar: const ui.SearchBar(placeholder: AppStrings.bibleSearchHint),
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
      saintsHeader: const ui.SectionHeader(title: 'Saints', showSeeAll: true),
      patronSaint: const ui.PatronSaintCard(
        id: 'patron-saint-athon',
        label: 'Your Patron Saint',
        name: 'Athon',
      ),
      patronSaintProfile: const ui.PatronSaintProfile(
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
      saintsShelf: const [],
      libraryHeader: const ui.SectionHeader(title: 'LIBRARY'),
      bibleShelf: const [
        ui.BookItem(id: 'book-bible', title: 'Bible'),
        ui.BookItem(id: 'book-andemta-commentary', title: 'Andemta Commentary'),
        ui.BookItem(id: 'book-daily-prayers', title: 'Daily Prayers'),
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

List<ReadingProgressData> _filterContinueReadingRows(
  List<ReadingProgressData> rows,
) {
  final result = <ReadingProgressData>[];
  var bibleIncluded = false;

  for (final row in rows) {
    final isBibleRow = _isBibleProgressId(row.bookId);
    if (isBibleRow) {
      if (bibleIncluded) {
        continue;
      }
      bibleIncluded = true;
    }
    result.add(row);
  }

  return result;
}

bool _isBibleProgressId(String id) {
  final trimmed = id.trim();
  return trimmed.isNotEmpty && !trimmed.startsWith('book-');
}

String _displayTitleForBookId(String id) {
  switch (id) {
    case 'book-daily-prayers':
      return 'Daily Prayers';
    case 'book-andemta-commentary':
      return 'Andemta Commentary';
    case 'book-bible':
      return 'Bible';
    case 'book-wudase-mariyam':
      return 'Wudase Mariyam';
    case 'book-psalms':
      return 'Psalms';
    case 'book-sene-gologota':
      return 'Sene Gologota';
    case 'book-seyfe-selase':
      return 'Seyfe Selase';
    case 'book-seyfe-melekot':
      return 'Seyfe Melekot';
  }
  return id
      .split('-')
      .where((part) => part.isNotEmpty && part != 'book')
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

import '../../content/explore_content_store.dart';
import '../../db/app_database.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

/// Explore sections are generated from the bundled content pack: a tile only
/// appears when its content entry exists, so empty sections simply hide.
class DbExploreRepository implements ExploreRepository {
  DbExploreRepository(this.db, this.store);

  final AppDatabase db;
  final ExploreContentStore store;

  @override
  Future<ExploreScreenState> fetchExploreScreen() async {
    var savedRows = <Object>[];
    try {
      savedRows = await db.savedItemsDao.listSavedItems();
    } catch (_) {
      // Keep Explore screen available even if local DB schema lags behind.
      savedRows = <Object>[];
    }
    final savedItems = savedRows
        .map(
          (row) => ui.SavedItem(
            id: '${(row as dynamic).id}',
            title: '${(row as dynamic).title}',
          ),
        )
        .toList();

    final studyEntries = await store.loadByKind(ExploreEntryKind.study);
    final pathEntries = await store.loadByKind(ExploreEntryKind.path);
    final communityEntries = await store.loadByKind(ExploreEntryKind.community);
    final contentEntries = await store.loadByKind(ExploreEntryKind.content);

    final categories = <String>[];
    for (final entry in contentEntries) {
      if (entry.category.isNotEmpty && !categories.contains(entry.category)) {
        categories.add(entry.category);
      }
    }

    final state = ExploreScreenState(
      topBar: const ui.ExploreTopBar(
        title: 'EXPLORE',
        subtitle: 'Learn, study, and grow in the Orthodox faith',
      ),
      studyHeader: const ui.SectionHeader(
        title: 'Sunbit Timhert Bet',
        subtitle:
            'Structured Orthodox learning from trusted books and teachings.',
      ),
      studyItems: studyEntries
          .map(
            (entry) => ui.ExploreCardItem(
              id: entry.id,
              title: entry.title,
              subtitle: entry.subtitle,
            ),
          )
          .toList(growable: false),
      guidedHeader: const ui.SectionHeader(
        title: 'Guided Paths',
        subtitle: 'Step-by-step learning journeys.',
      ),
      guidedPaths: pathEntries
          .map((entry) => ui.SmallTile(title: entry.title))
          .toList(growable: false),
      communityHeader: const ui.SectionHeader(
        title: 'Community',
        subtitle: 'Quiet Orthodox community space.',
      ),
      communityItems: communityEntries
          .map((entry) => ui.SmallTile(title: entry.title))
          .toList(growable: false),
      categoriesHeader: const ui.SectionHeader(title: 'Explore Categories'),
      categories: [
        const ui.CategoryChip(label: 'All'),
        ...categories.map((label) => ui.CategoryChip(label: label)),
      ],
      contentHeader: const ui.SectionHeader(title: 'Explore Content'),
      contentItems: contentEntries
          .map(
            (entry) => ui.ExploreContentItem(
              id: entry.id,
              title: entry.title,
              category: entry.category,
            ),
          )
          .toList(growable: false),
      savedHeader: const ui.SectionHeader(title: 'Saved Content'),
      savedItems: savedItems,
    );
    assert(() {
      assertValidExploreScreen(state);
      return true;
    }());
    return state;
  }
}

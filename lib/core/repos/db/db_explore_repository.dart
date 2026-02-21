import '../../db/app_database.dart';
import '../../models/ui_contract/ui_contract_models.dart' as ui;
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class DbExploreRepository implements ExploreRepository {
  DbExploreRepository(this.db);

  final AppDatabase db;

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
      studyItems: const [
        ui.ExploreCardItem(
          id: 'study-mistere-beta-kristiyan',
          title: 'Mistere Beta Kristiyan',
          subtitle: 'Foundations of the faith',
        ),
        ui.ExploreCardItem(
          id: 'study-life-in-church',
          title: 'Life in the Church',
          subtitle: 'Worship and community',
        ),
        ui.ExploreCardItem(
          id: 'study-sacraments',
          title: 'Sacraments of the Church',
          subtitle: 'Mysteries and grace',
        ),
      ],
      guidedHeader: const ui.SectionHeader(
        title: 'Guided Paths',
        subtitle: 'Step-by-step learning journeys.',
      ),
      guidedPaths: const [
        ui.SmallTile(title: 'New to Orthodoxy'),
        ui.SmallTile(title: 'Understanding the Liturgy'),
        ui.SmallTile(title: 'Living the Fast'),
      ],
      communityHeader: const ui.SectionHeader(
        title: 'Community',
        subtitle: 'Quiet Orthodox community space.',
      ),
      communityItems: const [
        ui.SmallTile(title: 'Ask a Question'),
        ui.SmallTile(title: 'Read Reflections'),
        ui.SmallTile(title: 'Community Prayers'),
      ],
      categoriesHeader: const ui.SectionHeader(title: 'Explore Categories'),
      categories: const [
        ui.CategoryChip(label: 'All'),
        ui.CategoryChip(label: 'Life in Christ'),
        ui.CategoryChip(label: 'Prayer & Worship'),
        ui.CategoryChip(label: 'Saints'),
        ui.CategoryChip(label: 'Fasting'),
        ui.CategoryChip(label: 'Theology'),
      ],
      contentHeader: const ui.SectionHeader(title: 'Explore Content'),
      contentItems: const [
        ui.ExploreContentItem(
          id: 'content-learning-hours',
          title: 'Learning the Hours',
          category: 'Prayer & Worship',
        ),
        ui.ExploreContentItem(
          id: 'content-saints-desert',
          title: 'Saints of the Desert',
          category: 'Saints',
        ),
        ui.ExploreContentItem(
          id: 'content-gospel-readings',
          title: 'The Gospel Readings',
          category: 'Life in Christ',
        ),
      ],
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

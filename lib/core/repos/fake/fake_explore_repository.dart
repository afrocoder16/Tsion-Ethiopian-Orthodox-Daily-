import '../../models/ui_contract/ui_contract_models.dart';
import '../guards/screen_state_guards.dart';
import '../screen_repositories.dart';
import '../screen_states.dart';

class FakeExploreRepository implements ExploreRepository {
  @override
  Future<ExploreScreenState> fetchExploreScreen() {
    final state = ExploreScreenState(
        topBar: const ExploreTopBar(
          title: 'EXPLORE',
          subtitle: 'Learn, study, and grow in the Orthodox faith',
        ),
        studyHeader: const SectionHeader(
          title: 'Sunbit Timhert Bet',
          subtitle: 'Structured Orthodox learning from trusted books and teachings.',
        ),
        studyItems: const [
          ExploreCardItem(
            id: 'study-mistere-beta-kristiyan',
            title: 'Mistere Betä Kristiyan',
            subtitle: 'Foundations of the faith',
          ),
          ExploreCardItem(
            id: 'study-life-in-church',
            title: 'Life in the Church',
            subtitle: 'Worship and community',
          ),
          ExploreCardItem(
            id: 'study-sacraments',
            title: 'Sacraments of the Church',
            subtitle: 'Mysteries and grace',
          ),
          ExploreCardItem(
            id: 'study-faith-tradition',
            title: 'Faith & Tradition',
            subtitle: 'Roots of Orthodox life',
          ),
        ],
        guidedHeader: const SectionHeader(
          title: 'Guided Paths',
          subtitle: 'Step-by-step learning journeys.',
        ),
        guidedPaths: const [
          SmallTile(title: 'New to Orthodoxy'),
          SmallTile(title: 'Understanding the Liturgy'),
          SmallTile(title: 'Living the Fast'),
        ],
        communityHeader: const SectionHeader(
          title: 'Community',
          subtitle: 'Quiet Orthodox community space.',
        ),
        communityItems: const [
          SmallTile(title: 'Ask a Question'),
          SmallTile(title: 'Read Reflections'),
          SmallTile(title: 'Community Prayers'),
        ],
        categoriesHeader: const SectionHeader(title: 'Explore Categories'),
        categories: const [
          CategoryChip(label: 'All'),
          CategoryChip(label: 'Life in Christ'),
          CategoryChip(label: 'Prayer & Worship'),
          CategoryChip(label: 'Saints'),
          CategoryChip(label: 'Fasting'),
          CategoryChip(label: 'Theology'),
        ],
        contentHeader: const SectionHeader(title: 'Explore Content'),
        contentItems: const [
          ExploreContentItem(
            id: 'content-learning-hours',
            title: 'Learning the Hours',
            category: 'Prayer & Worship',
          ),
          ExploreContentItem(
            id: 'content-saints-desert',
            title: 'Saints of the Desert',
            category: 'Saints',
          ),
          ExploreContentItem(
            id: 'content-gospel-readings',
            title: 'The Gospel Readings',
            category: 'Life in Christ',
          ),
        ],
        savedHeader: const SectionHeader(title: 'Saved Content'),
        savedItems: const [
          SavedItem(id: 'saved-faith-tradition', title: 'Faith & Tradition'),
          SavedItem(
            id: 'saved-understanding-liturgy',
            title: 'Understanding the Liturgy',
          ),
        ],
      );
    assert(() {
      assertValidExploreScreen(state);
      return true;
    }());
    return Future.value(state);
  }
}

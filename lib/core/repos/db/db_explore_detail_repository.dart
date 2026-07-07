import '../../content/explore_content_store.dart';
import '../explore_detail_repositories.dart';

class DbExploreDetailRepository implements ExploreDetailRepository {
  DbExploreDetailRepository(this.store);

  final ExploreContentStore store;

  @override
  Future<ExploreDetailState> fetchDetail(String id) async {
    final entry = await store.findById(id);
    if (entry == null) {
      throw StateError('Explore content not found: $id');
    }
    return ExploreDetailState(
      id: entry.id,
      title: entry.title,
      category: entry.category.isNotEmpty ? entry.category : 'Explore',
      body: entry.body,
    );
  }
}

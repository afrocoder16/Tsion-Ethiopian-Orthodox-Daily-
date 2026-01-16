import '../explore_detail_repositories.dart';

class FakeExploreDetailRepository implements ExploreDetailRepository {
  @override
  Future<ExploreDetailState> fetchDetail(String id) {
    final title = _titleFromId(id);
    return Future.value(
      ExploreDetailState(
        id: id,
        title: title,
        category: 'Explore',
        body: 'Placeholder detail content for $title.',
      ),
    );
  }
}

String _titleFromId(String id) {
  return id
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

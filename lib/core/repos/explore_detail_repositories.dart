class ExploreDetailState {
  const ExploreDetailState({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
  });

  final String id;
  final String title;
  final String category;
  final String body;
}

abstract class ExploreDetailRepository {
  Future<ExploreDetailState> fetchDetail(String id);
}

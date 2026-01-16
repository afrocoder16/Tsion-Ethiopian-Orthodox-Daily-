import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/explore_detail_repositories.dart';
import '../repos/fake/fake_explore_detail_repository.dart';

final exploreDetailRepositoryProvider = Provider<ExploreDetailRepository>(
  (ref) => FakeExploreDetailRepository(),
);

final exploreDetailProvider =
    FutureProvider.family.autoDispose<ExploreDetailState, String>(
  (ref, id) => ref.watch(exploreDetailRepositoryProvider).fetchDetail(id),
);

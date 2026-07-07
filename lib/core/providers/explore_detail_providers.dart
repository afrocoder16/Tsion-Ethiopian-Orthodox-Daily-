import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/db/db_explore_detail_repository.dart';
import '../repos/explore_detail_repositories.dart';
import '../repos/fake/fake_explore_detail_repository.dart';
import 'repo_providers.dart';

final exploreDetailRepositoryProvider = Provider<ExploreDetailRepository>((
  ref,
) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbExploreDetailRepository(ref.watch(exploreContentStoreProvider));
  }
  return FakeExploreDetailRepository();
});

final exploreDetailProvider = FutureProvider.family
    .autoDispose<ExploreDetailState, String>(
      (ref, id) => ref.watch(exploreDetailRepositoryProvider).fetchDetail(id),
    );

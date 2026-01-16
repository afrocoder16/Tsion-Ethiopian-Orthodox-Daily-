import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/db/db_streak_repository.dart';
import '../repos/fake/fake_streak_repository.dart';
import '../repos/streak_repositories.dart';
import 'repo_providers.dart';

final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (useDb) {
      return DbStreakRepository(ref.watch(dbProvider));
    }
    return FakeStreakRepository();
  },
);

final streakScreenProvider =
    FutureProvider.autoDispose<StreakScreenState>(
  (ref) => ref.watch(streakRepositoryProvider).fetchStreakScreen(),
);

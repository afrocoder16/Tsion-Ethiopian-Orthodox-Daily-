import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/bible/bible_asset_repository.dart';
import '../repos/book_flow_repositories.dart';
import '../repos/db/db_book_flow_repository.dart';
import '../repos/fake/fake_book_flow_repository.dart';
import 'repo_providers.dart';

final bookDetailRepositoryProvider = Provider<BookDetailRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (useDb) {
      return DbBookDetailRepository(ref.watch(dbProvider));
    }
    return FakeBookDetailRepository();
  },
);

final readerRepositoryProvider = Provider<ReaderRepository>(
  (ref) {
    final useDb = ref.watch(useDbReposProvider);
    if (useDb) {
      return DbReaderRepository(ref.watch(dbProvider));
    }
    return FakeReaderRepository();
  },
);

final bibleLibraryRepositoryProvider = Provider<BibleLibraryRepository>(
  (ref) => BibleAssetLibraryRepository(),
);

final passageRepositoryProvider = Provider<PassageRepository>(
  (ref) => BibleAssetPassageRepository(),
);

final bookDetailProvider =
    FutureProvider.family.autoDispose<BookDetailState, String>(
  (ref, id) => ref.watch(bookDetailRepositoryProvider).fetchDetail(id),
);

final readerProvider = FutureProvider.family.autoDispose<ReaderState, String>(
  (ref, id) => ref.watch(readerRepositoryProvider).fetchReader(id),
);

final bibleLibraryProvider =
    FutureProvider.autoDispose<BibleLibraryState>((ref) {
  return ref.watch(bibleLibraryRepositoryProvider).fetchLibrary();
});

final bibleChaptersProvider =
    FutureProvider.family.autoDispose<BibleBook?, String>((ref, bookId) async {
  final library = await ref.watch(bibleLibraryProvider.future);
  return library.bookById(bookId);
});

final passageProvider =
    FutureProvider.family.autoDispose<PassageState, (String, int)>(
  (ref, input) {
    final (bookId, chapter) = input;
    return ref.watch(passageRepositoryProvider).fetchPassage(bookId, chapter);
  },
);

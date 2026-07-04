import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repos/bible/bible_content_seeder.dart';
import '../repos/book_flow_repositories.dart';
import '../repos/db/db_book_flow_repository.dart';
import '../repos/fake/fake_book_flow_repository.dart';
import 'repo_providers.dart';

/// Persisted language preference for Bible text. 'am' = Amharic, 'en' = English.
final bibleLangProvider = StateNotifierProvider<BibleLangNotifier, String>(
  (ref) => BibleLangNotifier(),
);

class BibleLangNotifier extends StateNotifier<String> {
  BibleLangNotifier() : super('am') {
    _load();
  }

  static const _key = 'bible_language';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'am';
  }

  Future<void> setLang(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang);
  }
}

final bookDetailRepositoryProvider = Provider<BookDetailRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbBookDetailRepository(ref.watch(dbProvider));
  }
  return FakeBookDetailRepository();
});

final readerRepositoryProvider = Provider<ReaderRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbReaderRepository(ref.watch(dbProvider));
  }
  return FakeReaderRepository();
});

final bibleLibraryRepositoryProvider = Provider<BibleLibraryRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbBibleLibraryRepository(ref.watch(dbProvider));
  }
  return FakeBibleLibraryRepository();
});

final passageRepositoryProvider = Provider<PassageRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbPassageRepository(ref.watch(dbProvider));
  }
  return FakePassageRepository();
});

final bibleSearchRepositoryProvider = Provider<BibleSearchRepository>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (useDb) {
    return DbBibleSearchRepository(ref.watch(dbProvider));
  }
  return FakeBibleSearchRepository();
});

final bibleContentSeederProvider = Provider<BibleContentSeeder>(
  (ref) => BibleContentSeeder(db: ref.watch(dbProvider)),
);

final bibleSeedFutureProvider = FutureProvider<BibleSeedResult>((ref) {
  final useDb = ref.watch(useDbReposProvider);
  if (!useDb) {
    return Future.value(const BibleSeedResult(didSeed: false, verseCount: 0));
  }
  return ref.watch(bibleContentSeederProvider).seedIfNeeded();
});

final bookDetailProvider = FutureProvider.family
    .autoDispose<BookDetailState, String>(
      (ref, id) => ref.watch(bookDetailRepositoryProvider).fetchDetail(id),
    );

final readerProvider = FutureProvider.family.autoDispose<ReaderState, String>(
  (ref, id) => ref.watch(readerRepositoryProvider).fetchReader(id),
);

final bibleLibraryProvider = FutureProvider.autoDispose<BibleLibraryState>((
  ref,
) async {
  if (ref.watch(useDbReposProvider)) {
    await ref.watch(bibleSeedFutureProvider.future);
  }
  return ref.watch(bibleLibraryRepositoryProvider).fetchLibrary();
});

final bibleChaptersProvider = FutureProvider.family
    .autoDispose<BibleBook?, String>((ref, bookId) async {
      final library = await ref.watch(bibleLibraryProvider.future);
      return library.bookById(bookId);
    });

final passageProvider = FutureProvider.family
    .autoDispose<PassageState, (String, int, String)>((ref, input) async {
      final (bookId, chapter, lang) = input;
      if (ref.watch(useDbReposProvider)) {
        await ref.watch(bibleSeedFutureProvider.future);
      }
      return ref
          .watch(passageRepositoryProvider)
          .fetchPassage(bookId, chapter, lang: lang);
    });

final bibleSearchProvider = FutureProvider.family
    .autoDispose<List<BibleSearchResult>, (String, String)>((ref, input) async {
      final (query, lang) = input;
      if (ref.watch(useDbReposProvider)) {
        await ref.watch(bibleSeedFutureProvider.future);
      }
      return ref.watch(bibleSearchRepositoryProvider).search(query, lang: lang);
    });

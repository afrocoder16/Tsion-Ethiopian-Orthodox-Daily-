import '../../db/app_database.dart';
import '../book_flow_repositories.dart';
import '../fake/fake_book_flow_repository.dart';

class DbBookDetailRepository implements BookDetailRepository {
  DbBookDetailRepository(this.db);

  final AppDatabase db;

  @override
  Future<BookDetailState> fetchDetail(String id) async {
    final baseState = BookDetailState(
      id: id,
      title: _titleFromId(id),
      author: 'Unknown',
      description: 'Continue where you left off.',
      toc: const [
        'Introduction',
        'Chapter 1',
        'Chapter 2',
        'Chapter 3',
      ],
      isDownloaded: true,
      resumeLabel: 'Start reading',
    );

    final progress = await db.readingProgressDao.getReadingProgress(id);
    final resumeLabel = progress?.progressText ?? baseState.resumeLabel;

    return BookDetailState(
      id: id,
      title: _titleFromId(id),
      author: baseState.author,
      description: baseState.description,
      toc: baseState.toc,
      isDownloaded: baseState.isDownloaded,
      resumeLabel: resumeLabel,
    );
  }
}

class DbReaderRepository implements ReaderRepository {
  DbReaderRepository(this.db);

  final AppDatabase db;
  final FakeReaderRepository _fallback = FakeReaderRepository();

  @override
  Future<ReaderState> fetchReader(String id) async {
    final state = await _fallback.fetchReader(id);
    await db.readingProgressDao.upsertReadingProgress(
      bookId: id,
      lastLocation: state.chapterLabel,
      progressText: 'Resuming ${state.chapterLabel}',
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    return state;
  }
}

String _titleFromId(String id) {
  return id
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

class DbBibleLibraryRepository extends FakeBibleLibraryRepository {
  DbBibleLibraryRepository(this.db);

  final AppDatabase db;
}

class DbPassageRepository implements PassageRepository {
  DbPassageRepository(this.db);

  final AppDatabase db;
  final FakePassageRepository _fallback = FakePassageRepository();

  @override
  Future<PassageState> fetchPassage(String bookId, int chapter) async {
    final state = await _fallback.fetchPassage(bookId, chapter);
    return state;
  }
}

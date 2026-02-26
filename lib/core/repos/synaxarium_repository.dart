import '../calendar/calendar_engine_models.dart';

class SynaxariumIndexItem {
  const SynaxariumIndexItem({
    required this.key,
    required this.primarySaint,
    required this.saints,
    required this.needsReview,
    required this.sourceFile,
  });

  final String key;
  final String? primarySaint;
  final List<String> saints;
  final bool needsReview;
  final String sourceFile;
}

class SynaxariumEntry {
  const SynaxariumEntry({
    required this.key,
    required this.month,
    required this.day,
    required this.primarySaint,
    required this.saints,
    required this.text,
    required this.sourceFile,
    required this.needsReview,
  });

  final String key;
  final String month;
  final int day;
  final String? primarySaint;
  final List<String> saints;
  final String text;
  final String sourceFile;
  final bool needsReview;
}

class SynaxariumBookmarkItem {
  const SynaxariumBookmarkItem({
    required this.key,
    required this.primarySaint,
    required this.saints,
    required this.needsReview,
  });

  final String key;
  final String? primarySaint;
  final List<String> saints;
  final bool needsReview;
}

class SynaxariumSnippetBookmark {
  const SynaxariumSnippetBookmark({
    required this.id,
    required this.entryKey,
    required this.text,
    required this.createdAtIso,
  });

  final String id;
  final String entryKey;
  final String text;
  final String createdAtIso;
}

abstract class SynaxariumRepository {
  Future<SynaxariumIndexItem?> fetchIndexForDate(EthDate ethDate);

  Future<SynaxariumEntry?> fetchEntryForDate(EthDate ethDate);

  Future<SynaxariumEntry?> fetchEntryByKey(String key);

  Future<bool> isBookmarked(String key);

  Future<void> toggleBookmark(String key);

  Future<List<SynaxariumBookmarkItem>> fetchBookmarks();

  Future<void> addSnippetBookmark({
    required String entryKey,
    required String text,
  });

  Future<List<SynaxariumSnippetBookmark>> fetchSnippetBookmarks({
    String? entryKey,
  });

  Future<void> removeSnippetBookmark(String id);
}

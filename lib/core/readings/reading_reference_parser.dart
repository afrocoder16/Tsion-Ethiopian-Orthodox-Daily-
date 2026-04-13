import '../repos/bible/bible_asset_manifest.dart';
import 'reading_models.dart';

class ReadingReferenceParser {
  static const Map<String, String> _bookMap = {
    'gen': 'genesis',
    'exo': 'exodus',
    'lev': 'leviticus',
    'num': 'numbers',
    'deu': 'deuteronomy',
    'jos': 'joshua',
    'jdg': 'judges',
    'rut': 'ruth',
    '1sa': '1-samuel',
    '2sa': '2-samuel',
    '1ki': '1-kings',
    '2ki': '2-kings',
    '1ch': '1-chronicles',
    '2ch': '2-chronicles',
    'job': 'job',
    'pro': 'proverbs',
    'ecc': 'ecclesiastes',
    'isa': 'isaiah',
    'jer': 'jeremiah',
    'ezk': 'ezekiel',
    'dan': 'daniel',
    'hos': 'hosea',
    'amo': 'amos',
    'mic': 'micah',
    'joe': 'joel',
    'oba': 'obadiah',
    'jon': 'jonah',
    'nah': 'nahum',
    'hab': 'habakkuk',
    'zep': 'zephaniah',
    'hag': 'haggai',
    'zec': 'zechariah',
    'mal': 'malachi',
    'mat': 'matthew',
    'mt': 'matthew',
    'matt': 'matthew',
    'mrk': 'mark',
    'mk': 'mark',
    'luk': 'luke',
    'lk': 'luke',
    'luke': 'luke',
    'jhn': 'john',
    'jn': 'john',
    'joh': 'john',
    'act': 'acts',
    'ac': 'acts',
    'rom': 'romans',
    'rm': 'romans',
    '1cr': '1-corinthians',
    '2cr': '2-corinthians',
    'gal': 'galatians',
    'gl': 'galatians',
    'eph': 'ephesians',
    'ep': 'ephesians',
    'phl': 'philippians',
    'php': 'philippians',
    'phil': 'philippians',
    'col': 'colossians',
    '1th': '1-thessalonians',
    '2th': '2-thessalonians',
    '1ts': '1-thessalonians',
    '2ts': '2-thessalonians',
    '1tm': '1-timothy',
    '2tm': '2-timothy',
    '1ti': '1-timothy',
    '2ti': '2-timothy',
    'tt': 'titus',
    'tts': 'titus',
    'tit': 'titus',
    'phm': 'philemon',
    'hb': 'hebrews',
    'heb': 'hebrews',
    '1pt': '1-peter',
    '2pt': '2-peter',
    '1jn': '1-john',
    '2jn': '2-john',
    '3jn': '3-john',
    'jam': 'james',
    'jm': 'james',
    'jud': 'jude',
    'jd': 'jude',
    'ps': 'psalms',
  };

  static final Map<String, BibleAssetManifestEntry> _manifestById = {
    for (final item in bibleAssetManifest) item.id: item,
  };

  ReadingPassageReference parse(String source) {
    final original = source.trim();
    if (original.isEmpty) {
      return const ReadingPassageReference(
        source: '',
        book: null,
        bookId: null,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'empty',
      );
    }

    final normalized = original
        .replaceAll('.', '')
        .replaceAll(';', ',')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' - f', '-f')
        .replaceAll('- f', '-f')
        .replaceAll(' :', ':')
        .replaceAll(': ', ':')
        .replaceAll(' ,', ',')
        .trim();

    final match = RegExp(
      r'^([1-3]?\s*[A-Za-z]+)\s*(.*)$',
    ).firstMatch(normalized);
    if (match == null) {
      return ReadingPassageReference(
        source: original,
        book: null,
        bookId: null,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'unparsed',
      );
    }

    final rawBook = match.group(1)!.replaceAll(' ', '').toLowerCase();
    final bookId = _bookMap[rawBook];
    final manifestEntry = bookId == null ? null : _manifestById[bookId];
    final rest = match.group(2)!.trim();
    if (bookId == null || manifestEntry == null) {
      return ReadingPassageReference(
        source: original,
        book: match.group(1),
        bookId: null,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'book_unmapped',
      );
    }

    if (rest.isEmpty) {
      return ReadingPassageReference(
        source: original,
        book: manifestEntry.en,
        bookId: manifestEntry.id,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'missing_reference',
      );
    }

    if (bookId == 'psalms') {
      return _parsePsalm(original, manifestEntry.en, manifestEntry.id, rest);
    }

    if (rest.contains(':')) {
      return _parseVerseReference(
        original,
        manifestEntry.en,
        manifestEntry.id,
        rest,
      );
    }
    return _parseChapterReference(
      original,
      manifestEntry.en,
      manifestEntry.id,
      rest,
    );
  }

  ReadingPassageReference _parsePsalm(
    String source,
    String book,
    String bookId,
    String rest,
  ) {
    final cleaned = rest.replaceAll(' ', '');
    final match = RegExp(
      r'^(\d+):([\d,-]+|[\d,]+|[\d]+-f)$',
    ).firstMatch(cleaned);
    if (match == null) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'unparsed_psalm',
      );
    }
    final sourcePsalmNumber = int.parse(match.group(1)!);
    final versePart = match.group(2)!;
    if (versePart.contains(',') && !versePart.contains('-')) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.verseList,
        chapter: sourcePsalmNumber,
        verses: versePart
            .split(',')
            .where((item) => item.trim().isNotEmpty)
            .map((item) => int.parse(item.trim()))
            .toList(growable: false),
        sourcePsalmNumber: sourcePsalmNumber,
        biblePsalmNumber: sourcePsalmNumber,
      );
    }
    final range = _parseVerseBounds(versePart);
    return ReadingPassageReference(
      source: source,
      book: book,
      bookId: bookId,
      kind: ReadingReferenceKind.verseRange,
      chapter: sourcePsalmNumber,
      fromVerse: range.$1,
      toVerse: range.$2,
      toChapterEnd: range.$3,
      sourcePsalmNumber: sourcePsalmNumber,
      biblePsalmNumber: sourcePsalmNumber,
    );
  }

  ReadingPassageReference _parseVerseReference(
    String source,
    String book,
    String bookId,
    String rest,
  ) {
    final cleaned = rest.replaceAll(' ', '');
    final parts = cleaned.split(':');
    if (parts.length != 2) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'unparsed_verse_reference',
      );
    }
    final chapter = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
    if (chapter == null) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'missing_chapter',
      );
    }
    final versePart = parts[1];
    if (versePart.contains(',') && !versePart.contains('-')) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.verseList,
        chapter: chapter,
        verses: versePart
            .split(',')
            .where((item) => item.trim().isNotEmpty)
            .map((item) => int.parse(item.trim()))
            .toList(growable: false),
      );
    }
    final bounds = _parseVerseBounds(versePart);
    return ReadingPassageReference(
      source: source,
      book: book,
      bookId: bookId,
      kind: ReadingReferenceKind.verseRange,
      chapter: chapter,
      fromChapter: chapter,
      toChapter: chapter,
      fromVerse: bounds.$1,
      toVerse: bounds.$2,
      toChapterEnd: bounds.$3,
    );
  }

  ReadingPassageReference _parseChapterReference(
    String source,
    String book,
    String bookId,
    String rest,
  ) {
    final cleaned = rest.replaceAll(' ', '');
    final numbers = cleaned
        .split(',')
        .map((item) => item.replaceAll(RegExp(r'[^0-9]'), ''))
        .where((item) => item.isNotEmpty)
        .map(int.parse)
        .toList(growable: false);
    if (numbers.isEmpty) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.raw,
        parseStatus: 'missing_chapter',
      );
    }
    if (numbers.length == 1) {
      return ReadingPassageReference(
        source: source,
        book: book,
        bookId: bookId,
        kind: ReadingReferenceKind.wholeChapter,
        chapter: numbers.first,
      );
    }
    return ReadingPassageReference(
      source: source,
      book: book,
      bookId: bookId,
      kind: ReadingReferenceKind.chapterRange,
      fromChapter: numbers.first,
      toChapter: numbers.last,
    );
  }

  (int, int?, bool) _parseVerseBounds(String value) {
    final trimmed = value.trim();
    final toChapterEnd = trimmed.toLowerCase().endsWith('f');
    final cleaned = trimmed.replaceAll('f', '').replaceAll('F', '');
    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      final start = int.parse(parts.first);
      final end = parts.length > 1 && parts.last.trim().isNotEmpty
          ? int.tryParse(parts.last.trim())
          : null;
      return (start, end, toChapterEnd);
    }
    final single = int.parse(cleaned);
    return (single, single, toChapterEnd);
  }
}

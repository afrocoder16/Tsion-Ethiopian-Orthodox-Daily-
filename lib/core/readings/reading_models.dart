class ReadingPlanMonth {
  const ReadingPlanMonth({
    required this.schemaVersion,
    required this.sourceName,
    required this.yearType,
    required this.rows,
  });

  final String schemaVersion;
  final String sourceName;
  final String yearType;
  final List<ReadingPlanDay> rows;

  factory ReadingPlanMonth.fromJson(Map<String, dynamic> json) {
    return ReadingPlanMonth(
      schemaVersion: '${json['schema_version'] ?? '1.0'}',
      sourceName: '${json['source_name'] ?? ''}',
      yearType: '${json['year_type'] ?? ''}',
      rows: (json['rows'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => ReadingPlanDay.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReadingPlanDay {
  const ReadingPlanDay({
    required this.ethMonth,
    required this.ethDay,
    required this.gregorianDisplay,
    required this.morning,
    required this.qidase,
    required this.anaphora,
    required this.evening,
    required this.sourceMeta,
    this.ethMonthName,
    this.morningStatus,
    this.sourceRowNote,
  });

  final int ethMonth;
  final int ethDay;
  final String? ethMonthName;
  final String gregorianDisplay;
  final String? morningStatus;
  final List<String> morning;
  final ReadingPlanQidase qidase;
  final AnaphoraInfo anaphora;
  final List<String> evening;
  final SourceMeta sourceMeta;
  final String? sourceRowNote;

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    return ReadingPlanDay(
      ethMonth: json['eth_month'] as int,
      ethDay: json['eth_day'] as int,
      ethMonthName: json['eth_month_name'] as String?,
      gregorianDisplay: '${json['gregorian_display'] ?? ''}',
      morningStatus: json['morning_status'] as String?,
      morning: (json['morning'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => '$item')
          .toList(growable: false),
      qidase: ReadingPlanQidase.fromJson(
        json['qidase'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      anaphora: AnaphoraInfo.fromJson(
        json['anaphora'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      evening: (json['evening'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => '$item')
          .toList(growable: false),
      sourceMeta: SourceMeta.fromJson(
        json['source_meta'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      sourceRowNote: json['source_row_note'] as String?,
    );
  }
}

class ReadingPlanQidase {
  const ReadingPlanQidase({
    this.matinsPsalm,
    this.matinsGospel,
    this.pauline,
    this.catholic,
    this.acts,
    this.psalm,
    this.gospel,
  });

  final String? matinsPsalm;
  final String? matinsGospel;
  final String? pauline;
  final String? catholic;
  final String? acts;
  final String? psalm;
  final String? gospel;

  List<String> get orderedSources {
    return [
      if (matinsPsalm != null && matinsPsalm!.trim().isNotEmpty) matinsPsalm!,
      if (matinsGospel != null && matinsGospel!.trim().isNotEmpty)
        matinsGospel!,
      if (pauline != null && pauline!.trim().isNotEmpty) pauline!,
      if (catholic != null && catholic!.trim().isNotEmpty) catholic!,
      if (acts != null && acts!.trim().isNotEmpty) acts!,
      if (psalm != null && psalm!.trim().isNotEmpty) psalm!,
      if (gospel != null && gospel!.trim().isNotEmpty) gospel!,
    ];
  }

  List<String> get orderedLabels {
    return [
      if (matinsPsalm != null && matinsPsalm!.trim().isNotEmpty) 'Matins Psalm',
      if (matinsGospel != null && matinsGospel!.trim().isNotEmpty)
        'Matins Gospel',
      if (pauline != null && pauline!.trim().isNotEmpty) 'Pauline',
      if (catholic != null && catholic!.trim().isNotEmpty) 'Catholic',
      if (acts != null && acts!.trim().isNotEmpty) 'Acts',
      if (psalm != null && psalm!.trim().isNotEmpty) 'Psalm',
      if (gospel != null && gospel!.trim().isNotEmpty) 'Gospel',
    ];
  }

  factory ReadingPlanQidase.fromJson(Map<String, dynamic> json) {
    return ReadingPlanQidase(
      matinsPsalm: json['matins_psalm'] as String?,
      matinsGospel: json['matins_gospel'] as String?,
      pauline: json['pauline'] as String?,
      catholic: json['catholic'] as String?,
      acts: json['acts'] as String?,
      psalm: json['psalm'] as String?,
      gospel: json['gospel'] as String?,
    );
  }
}

class AnaphoraInfo {
  const AnaphoraInfo({required this.sourceNumber, required this.resolvedName});

  final int sourceNumber;
  final String resolvedName;

  factory AnaphoraInfo.fromJson(Map<String, dynamic> json) {
    return AnaphoraInfo(
      sourceNumber: json['source_number'] as int? ?? 0,
      resolvedName: '${json['resolved_name'] ?? ''}',
    );
  }
}

class SourceMeta {
  const SourceMeta({
    required this.document,
    required this.rowLabel,
    required this.qaStatus,
  });

  final String document;
  final String rowLabel;
  final String qaStatus;

  bool get isTrusted => qaStatus == 'extracted_from_pdf_text';

  factory SourceMeta.fromJson(Map<String, dynamic> json) {
    return SourceMeta(
      document: '${json['document'] ?? ''}',
      rowLabel: '${json['row_label'] ?? ''}',
      qaStatus: '${json['qa_status'] ?? ''}',
    );
  }
}

enum ReadingReferenceKind {
  wholeChapter,
  chapterRange,
  verseRange,
  verseList,
  raw,
}

class ReadingPassageReference {
  const ReadingPassageReference({
    required this.source,
    required this.book,
    required this.bookId,
    required this.kind,
    this.chapter,
    this.fromChapter,
    this.toChapter,
    this.fromVerse,
    this.toVerse,
    this.verses = const <int>[],
    this.toChapterEnd = false,
    this.parseStatus = 'parsed',
    this.sourcePsalmNumber,
    this.biblePsalmNumber,
  });

  final String source;
  final String? book;
  final String? bookId;
  final ReadingReferenceKind kind;
  final int? chapter;
  final int? fromChapter;
  final int? toChapter;
  final int? fromVerse;
  final int? toVerse;
  final List<int> verses;
  final bool toChapterEnd;
  final String parseStatus;
  final int? sourcePsalmNumber;
  final int? biblePsalmNumber;

  bool get isParsed => bookId != null && parseStatus == 'parsed';
}

class ResolvedPassageVerse {
  const ResolvedPassageVerse({
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final int chapter;
  final int verse;
  final String text;
}

class ResolvedPassageText {
  const ResolvedPassageText({
    required this.bookId,
    required this.bookTitle,
    required this.verses,
  });

  final String bookId;
  final String bookTitle;
  final List<ResolvedPassageVerse> verses;

  String get combinedText =>
      verses.map((item) => '${item.verse}. ${item.text}').join(' ');
}

class ReadingPassage {
  const ReadingPassage({required this.reference, this.resolvedText, this.note});

  final ReadingPassageReference reference;
  final ResolvedPassageText? resolvedText;
  final String? note;
}

class ReadingSection {
  const ReadingSection({
    required this.id,
    required this.title,
    required this.passages,
  });

  final String id;
  final String title;
  final List<ReadingPassage> passages;
}

class DailyReadingsResult {
  const DailyReadingsResult({
    required this.day,
    required this.sections,
    required this.isLoaded,
  });

  final ReadingPlanDay? day;
  final List<ReadingSection> sections;
  final bool isLoaded;
}

class DailyVerseEntry {
  const DailyVerseEntry({
    required this.id,
    required this.title,
    required this.reference,
    required this.body,
    required this.fullBody,
    this.isPreviewTruncated = false,
    this.bookId,
    this.chapter,
    this.verse,
    this.verseEnd,
  });

  final String id;
  final String title;
  final String reference;
  final String body;
  final String fullBody;
  final bool isPreviewTruncated;
  final String? bookId;
  final int? chapter;
  final int? verse;
  final int? verseEnd;

  factory DailyVerseEntry.fromJson(Map<String, dynamic> json) {
    return DailyVerseEntry(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      reference: '${json['reference'] ?? ''}',
      body: '${json['body'] ?? ''}',
      fullBody: '${json['full_body'] ?? json['body'] ?? ''}',
      isPreviewTruncated: json['is_preview_truncated'] as bool? ?? false,
      bookId: json['book_id'] as String?,
      chapter: json['chapter'] as int?,
      verse: json['verse'] as int?,
      verseEnd: json['verse_end'] as int?,
    );
  }
}

class DailyVerseSupportingEntry {
  const DailyVerseSupportingEntry({
    required this.label,
    required this.reference,
    required this.previewBody,
    required this.bookId,
    required this.chapter,
    this.verse,
    this.verseEnd,
    this.isPreviewTruncated = false,
  });

  final String label;
  final String reference;
  final String previewBody;
  final String bookId;
  final int chapter;
  final int? verse;
  final int? verseEnd;
  final bool isPreviewTruncated;
}

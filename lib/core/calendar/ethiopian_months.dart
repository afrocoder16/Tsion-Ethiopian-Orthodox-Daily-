/// Single source of truth for Ethiopian month names and the spelling
/// variants that appear across the bundled content datasets.
///
/// Months are 1-indexed (1 = Meskerem ... 13 = Pagume). Content JSON uses
/// inconsistent transliterations (e.g. Tekemt/Tikimt, Hedar/Hidar), so
/// repositories that match dataset keys should go through [aliasesFor] or
/// [monthOrderOf] instead of keeping their own tables.
library;

abstract final class EthiopianMonths {
  /// Canonical English transliterations, index 0 = Meskerem.
  static const List<String> english = [
    'Meskerem',
    'Tikimt',
    'Hedar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  /// Known dataset spellings per month, first entry is the spelling most
  /// common in the bundled JSON. Used to look up month keys in content packs.
  static const Map<int, List<String>> aliases = {
    1: ['Meskerem'],
    2: ['Tekemt', 'Tikimt'],
    3: ['Hedar', 'Hidar'],
    4: ['Tahisas', 'Tahsas'],
    5: ['Tir', 'Ter'],
    6: ['Yekatit'],
    7: ['Megabit'],
    8: ['Miyazia', 'Miyazya'],
    9: ['Ginbot'],
    10: ['Senne', 'Sene'],
    11: ['Hamle'],
    12: ['Nehasse', 'Nehase'],
    13: ['Pagumen', 'Pagume'],
  };

  /// Canonical English name for a 1-indexed [month]; clamps out-of-range
  /// values to the nearest valid month.
  static String englishName(int month) =>
      english[(month - 1).clamp(0, 12).toInt()];

  /// All known spellings for a 1-indexed [month].
  static List<String> aliasesFor(int month) => aliases[month] ?? const [];

  /// 1-indexed month for a dataset spelling, or null when unknown.
  static int? monthOrderOf(String name) {
    for (final entry in aliases.entries) {
      if (entry.value.contains(name)) {
        return entry.key;
      }
    }
    return null;
  }
}

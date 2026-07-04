import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/core/calendar/calendar_engine.dart';
import 'package:tsion_orthodox_daily_app/core/calendar/calendar_engine_models.dart';

void main() {
  group('CalendarEngine golden dates', () {
    late CalendarEngine engine;

    setUp(() {
      engine = CalendarEngine();
    });

    test('calculates Fasika and Nineveh anchors for Ethiopian years', () {
      final cases = [
        _MovableDateCase(
          ethYear: 2016,
          fasikaGregorian: DateTime(2024, 5, 5),
          ninevehGregorian: DateTime(2024, 2, 26),
        ),
        _MovableDateCase(
          ethYear: 2017,
          fasikaGregorian: DateTime(2025, 4, 20),
          ninevehGregorian: DateTime(2025, 2, 10),
        ),
      ];

      for (final current in cases) {
        final anchors = engine.getAnchorsForYear(current.ethYear);

        expect(
          _ymd(engine.gregorianFromEthDate(anchors.easter)),
          _ymd(current.fasikaGregorian),
          reason: 'Fasika for Ethiopian year ${current.ethYear}',
        );
        expect(
          _ymd(engine.gregorianFromEthDate(anchors.nenewe)),
          _ymd(current.ninevehGregorian),
          reason: 'Nineveh fast start for Ethiopian year ${current.ethYear}',
        );

        final fasika = engine.getDayObservance(current.fasikaGregorian);
        expect(_feastIds(fasika), contains('EASTER'));
        expect(fasika.fastStatus.isFastingDay, isFalse);

        final nineveh = engine.getDayObservance(current.ninevehGregorian);
        expect(nineveh.weekdayKey, 'Monday');
        expect(nineveh.fastStatus.isFastingDay, isTrue);
        expect(nineveh.fastStatus.seasonId, 'NENEWE');
        expect(nineveh.fastStatus.seasonStart, _sameEthDate(anchors.nenewe));
      }
    });

    test('recognizes fixed feasts across shifted and ordinary years', () {
      final cases = [
        _FixedFeastCase(
          gregorianDate: DateTime(2023, 9, 28),
          ethDate: const EthDate(year: 2016, month: 1, day: 17),
          feastId: 'MESKEL',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2024, 1, 8),
          ethDate: const EthDate(year: 2016, month: 4, day: 29),
          feastId: 'GENNA',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2024, 1, 20),
          ethDate: const EthDate(year: 2016, month: 5, day: 11),
          feastId: 'TIMKET',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2024, 8, 22),
          ethDate: const EthDate(year: 2016, month: 12, day: 16),
          feastId: 'FILSETA_FEAST',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2024, 9, 27),
          ethDate: const EthDate(year: 2017, month: 1, day: 17),
          feastId: 'MESKEL',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2025, 1, 7),
          ethDate: const EthDate(year: 2017, month: 4, day: 29),
          feastId: 'GENNA',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2025, 1, 19),
          ethDate: const EthDate(year: 2017, month: 5, day: 11),
          feastId: 'TIMKET',
        ),
        _FixedFeastCase(
          gregorianDate: DateTime(2025, 8, 22),
          ethDate: const EthDate(year: 2017, month: 12, day: 16),
          feastId: 'FILSETA_FEAST',
        ),
      ];

      for (final current in cases) {
        final observance = engine.getDayObservance(current.gregorianDate);

        expect(
          observance.ethDate,
          _sameEthDate(current.ethDate),
          reason: _ymd(current.gregorianDate),
        );
        expect(_feastIds(observance), contains(current.feastId));
      }
    });

    test('waives Wed and Fri fasts during the 50 days after Fasika', () {
      final eastertideDates = [DateTime(2024, 5, 8), DateTime(2024, 5, 10)];

      for (final current in eastertideDates) {
        final observance = engine.getDayObservance(current);

        expect(observance.fastStatus.isFastingDay, isFalse);
        expect(observance.fastStatus.reasons, isNot(contains('WED_FRI')));
      }
    });

    test('marks ordinary Wed and Fri dates as fasting days', () {
      final ordinaryFastDates = [DateTime(2024, 1, 31), DateTime(2024, 2, 2)];

      for (final current in ordinaryFastDates) {
        final observance = engine.getDayObservance(current);

        expect(observance.fastStatus.isFastingDay, isTrue);
        expect(observance.fastStatus.reasons, contains('WED_FRI'));
        expect(observance.fastStatus.seasonId, isNull);
      }
    });

    test('handles Ethiopian year boundaries on Meskerem 1', () {
      final cases = [
        _DateConversionCase(
          gregorianDate: DateTime(2023, 9, 11),
          ethDate: const EthDate(year: 2015, month: 13, day: 6),
        ),
        _DateConversionCase(
          gregorianDate: DateTime(2023, 9, 12),
          ethDate: const EthDate(year: 2016, month: 1, day: 1),
        ),
        _DateConversionCase(
          gregorianDate: DateTime(2024, 9, 10),
          ethDate: const EthDate(year: 2016, month: 13, day: 5),
        ),
        _DateConversionCase(
          gregorianDate: DateTime(2024, 9, 11),
          ethDate: const EthDate(year: 2017, month: 1, day: 1),
        ),
      ];

      for (final current in cases) {
        expect(
          engine.ethDateFromGregorian(current.gregorianDate),
          _sameEthDate(current.ethDate),
          reason: _ymd(current.gregorianDate),
        );
        expect(
          _ymd(engine.gregorianFromEthDate(current.ethDate)),
          _ymd(current.gregorianDate),
          reason: current.ethDate.key,
        );
      }
    });

    test('returns Bahire Hasab stats for tested Ethiopian years', () {
      final cases = [
        _BahireHasabCase(
          ethYear: 2016,
          evangelistPrefix: 'John',
          ameteAlem: 7516,
          wenber: 10,
          abekte: 20,
          metkih: 10,
        ),
        _BahireHasabCase(
          ethYear: 2017,
          evangelistPrefix: 'Matthew',
          ameteAlem: 7517,
          wenber: 11,
          abekte: 1,
          metkih: 29,
        ),
      ];

      for (final current in cases) {
        final stats = engine.getBahireHasabStatsForYear(current.ethYear);

        expect(stats.evangelist, startsWith(current.evangelistPrefix));
        expect(stats.ameteAlem, current.ameteAlem);
        expect(stats.wenber, current.wenber);
        expect(stats.abekte, current.abekte);
        expect(stats.metkih, current.metkih);
      }
    });
  });
}

Matcher _sameEthDate(EthDate expected) {
  return isA<EthDate>()
      .having((date) => date.year, 'year', expected.year)
      .having((date) => date.month, 'month', expected.month)
      .having((date) => date.day, 'day', expected.day);
}

Set<String> _feastIds(DayObservance observance) {
  return observance.feasts.map((feast) => feast.id).toSet();
}

String _ymd(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class _MovableDateCase {
  const _MovableDateCase({
    required this.ethYear,
    required this.fasikaGregorian,
    required this.ninevehGregorian,
  });

  final int ethYear;
  final DateTime fasikaGregorian;
  final DateTime ninevehGregorian;
}

class _FixedFeastCase {
  const _FixedFeastCase({
    required this.gregorianDate,
    required this.ethDate,
    required this.feastId,
  });

  final DateTime gregorianDate;
  final EthDate ethDate;
  final String feastId;
}

class _DateConversionCase {
  const _DateConversionCase({
    required this.gregorianDate,
    required this.ethDate,
  });

  final DateTime gregorianDate;
  final EthDate ethDate;
}

class _BahireHasabCase {
  const _BahireHasabCase({
    required this.ethYear,
    required this.evangelistPrefix,
    required this.ameteAlem,
    required this.wenber,
    required this.abekte,
    required this.metkih,
  });

  final int ethYear;
  final String evangelistPrefix;
  final int ameteAlem;
  final int wenber;
  final int abekte;
  final int metkih;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tsion_orthodox_daily_app/core/onboarding/onboarding_schedule.dart';

void main() {
  test('four-time preset builds the default prayer rhythm', () {
    final slots = slotsForPreset(OnboardingPrayerPreset.fourTime);

    expect(slots, hasLength(4));
    expect(slots.map((slot) => slot.timeLocal), [
      '06:00',
      '12:00',
      '18:00',
      '21:00',
    ]);
    expect(slots.where((slot) => slot.isEnabled), hasLength(3));
  });

  test('seven-time preset builds seven ordered prayer slots', () {
    final slots = slotsForPreset(OnboardingPrayerPreset.sevenTime);

    expect(slots, hasLength(7));
    expect(slots.first.label, 'Morning');
    expect(slots.last.label, 'Midnight');
  });

  test('custom preset preserves edited slots', () {
    final custom = [
      fourTimePrayerPreset.first.copyWith(timeLocal: '05:30', isEnabled: false),
    ];

    final slots = slotsForPreset(
      OnboardingPrayerPreset.custom,
      customSlots: custom,
    );

    expect(slots, hasLength(1));
    expect(slots.single.timeLocal, '05:30');
    expect(slots.single.isEnabled, isFalse);
  });
}

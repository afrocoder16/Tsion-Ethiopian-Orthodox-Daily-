enum OnboardingPrayerPreset { fourTime, sevenTime, custom }

class OnboardingPrayerSlot {
  const OnboardingPrayerSlot({
    required this.slotId,
    required this.label,
    required this.timeLocal,
    required this.isEnabled,
  });

  final int slotId;
  final String label;
  final String timeLocal;
  final bool isEnabled;

  OnboardingPrayerSlot copyWith({String? timeLocal, bool? isEnabled}) {
    return OnboardingPrayerSlot(
      slotId: slotId,
      label: label,
      timeLocal: timeLocal ?? this.timeLocal,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

const fourTimePrayerPreset = [
  OnboardingPrayerSlot(
    slotId: 1,
    label: 'Morning',
    timeLocal: '06:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 2,
    label: 'Noon',
    timeLocal: '12:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 3,
    label: 'Evening',
    timeLocal: '18:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 4,
    label: 'Night',
    timeLocal: '21:00',
    isEnabled: false,
  ),
];

const sevenTimePrayerPreset = [
  OnboardingPrayerSlot(
    slotId: 1,
    label: 'Morning',
    timeLocal: '06:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 2,
    label: 'Third Hour',
    timeLocal: '09:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 3,
    label: 'Sixth Hour',
    timeLocal: '12:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 4,
    label: 'Ninth Hour',
    timeLocal: '15:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 5,
    label: 'Evening',
    timeLocal: '18:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 6,
    label: 'Compline',
    timeLocal: '21:00',
    isEnabled: true,
  ),
  OnboardingPrayerSlot(
    slotId: 7,
    label: 'Midnight',
    timeLocal: '00:00',
    isEnabled: false,
  ),
];

List<OnboardingPrayerSlot> slotsForPreset(
  OnboardingPrayerPreset preset, {
  List<OnboardingPrayerSlot> customSlots = fourTimePrayerPreset,
}) {
  switch (preset) {
    case OnboardingPrayerPreset.fourTime:
      return List<OnboardingPrayerSlot>.from(fourTimePrayerPreset);
    case OnboardingPrayerPreset.sevenTime:
      return List<OnboardingPrayerSlot>.from(sevenTimePrayerPreset);
    case OnboardingPrayerPreset.custom:
      return List<OnboardingPrayerSlot>.from(customSlots);
  }
}

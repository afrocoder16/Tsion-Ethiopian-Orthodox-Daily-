class PrayerDetailState {
  const PrayerDetailState({
    required this.id,
    required this.title,
    required this.stillnessTitle,
    required this.stillnessBody,
    required this.body,
    required this.slotId,
  });

  final String id;
  final String title;
  final String stillnessTitle;
  final String stillnessBody;
  final String body;
  final int slotId;
}

const Map<String, int> _prayerSlotIds = {
  'prayer-midday': 1,
  'trisagion-prayers': 2,
  'psalm-50': 3,
  'prayer-of-st-ephrem': 4,
};

int slotIdForPrayer(String id) => _prayerSlotIds[id] ?? 0;

String idForSlotId(int slotId) {
  for (final entry in _prayerSlotIds.entries) {
    if (entry.value == slotId) {
      return entry.key;
    }
  }
  return 'prayer-midday';
}

abstract class PrayerDetailRepository {
  Future<PrayerDetailState> fetchDetail(String id);
}

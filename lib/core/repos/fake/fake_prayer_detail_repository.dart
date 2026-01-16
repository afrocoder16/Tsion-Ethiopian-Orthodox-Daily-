import '../prayer_flow_repositories.dart';

class FakePrayerDetailRepository implements PrayerDetailRepository {
  @override
  Future<PrayerDetailState> fetchDetail(String id) {
    final title = _titleFromId(id);
    return Future.value(
      PrayerDetailState(
        id: id,
        title: title,
        stillnessTitle: 'Opening stillness',
        stillnessBody: 'Take a moment of silence before prayer.',
        body: 'This is placeholder text for $title. Continue in quiet focus.',
        slotId: slotIdForPrayer(id),
      ),
    );
  }
}

String _titleFromId(String id) {
  final parts = id.split('-');
  return parts
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

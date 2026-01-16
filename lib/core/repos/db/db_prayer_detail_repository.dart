import '../../db/app_database.dart';
import '../fake/fake_prayer_detail_repository.dart';
import '../prayer_flow_repositories.dart';

class DbPrayerDetailRepository implements PrayerDetailRepository {
  DbPrayerDetailRepository(this.db);

  final AppDatabase db;
  final FakePrayerDetailRepository _fallback = FakePrayerDetailRepository();

  @override
  Future<PrayerDetailState> fetchDetail(String id) {
    return _fallback.fetchDetail(id);
  }
}

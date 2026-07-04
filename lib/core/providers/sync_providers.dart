import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/user_data_sync.dart';
import 'auth_providers.dart';
import 'repo_providers.dart';

final userDataRemoteStoreProvider = Provider<UserDataRemoteStore>(
  (ref) => FirestoreUserDataRemoteStore(),
);

final userDataSyncServiceProvider = FutureProvider<UserDataSyncService?>((
  ref,
) async {
  final session = await ref.watch(authSessionProvider.future);
  if (!session.isSignedIn) {
    return null;
  }
  final user = session.user;
  if (user == null) {
    return null;
  }
  return UserDataSyncService(
    db: ref.watch(dbProvider),
    uid: user.uid,
    remote: ref.watch(userDataRemoteStoreProvider),
  );
});

final userDataSyncBootstrapProvider = FutureProvider<void>((ref) async {
  final service = await ref.watch(userDataSyncServiceProvider.future);
  if (service == null) {
    return;
  }
  await service.flushQueue();
  await service.pullRemoteChanges();
});

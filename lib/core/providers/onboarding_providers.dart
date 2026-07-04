import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding/onboarding_repository.dart';
import 'notification_providers.dart';
import 'repo_providers.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(
    db: ref.watch(dbProvider),
    notificationService: ref.watch(prayerNotificationServiceProvider),
  );
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingRepositoryProvider).isComplete();
});

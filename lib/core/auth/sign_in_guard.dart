import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_paths.dart';
import '../providers/auth_providers.dart';
import '../strings/app_strings.dart';

enum SignInFeature {
  bookmarks,
  streak,
  personalPrayerList,
  mezmurPlayback,
  lightCandle,
  dailyReflection,
  prayerCompletion,
  profile,
}

final signInGuardProvider = Provider<SignInGuard>((ref) => SignInGuard(ref));

class SignInGuard {
  const SignInGuard(this.ref);

  final Ref ref;

  bool get isSignedIn {
    final session = ref.read(authSessionProvider).asData?.value;
    return session?.isSignedIn == true;
  }

  Future<bool> ensureSignedIn(
    BuildContext context, {
    required SignInFeature feature,
  }) async {
    if (isSignedIn) {
      return true;
    }
    final current = ref.read(authSessionProvider);
    if (current.isLoading) {
      try {
        final session = await ref
            .read(authSessionProvider.future)
            .timeout(const Duration(seconds: 3));
        if (session.isSignedIn) {
          return true;
        }
      } catch (_) {
        // Fall through to the prompt when auth state cannot be resolved.
      }
    }
    if (!context.mounted) {
      return false;
    }
    await showSignInUnlockPrompt(context, feature: feature);
    return false;
  }

  Future<T?> run<T>(
    BuildContext context, {
    required SignInFeature feature,
    required FutureOr<T> Function() action,
  }) async {
    final allowed = await ensureSignedIn(context, feature: feature);
    if (!allowed) {
      return null;
    }
    return action();
  }
}

class SignInGate extends ConsumerWidget {
  const SignInGate({super.key, required this.feature, required this.child});

  final SignInFeature feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return session.when(
      data: (value) {
        if (value.isSignedIn) {
          return child;
        }
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SignInUnlockPrompt(
                  feature: feature,
                  onSignIn: () => context.push(RoutePaths.profileSignInPath()),
                  onNotNow: () => _dismissGate(context),
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SignInUnlockPrompt(
                feature: feature,
                onSignIn: () => context.push(RoutePaths.profileSignInPath()),
                onNotNow: () => _dismissGate(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _dismissGate(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(RoutePaths.today);
}

Future<void> showSignInUnlockPrompt(
  BuildContext context, {
  required SignInFeature feature,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SignInUnlockPrompt(
        feature: feature,
        onSignIn: () {
          Navigator.of(dialogContext).pop();
          Future.microtask(() {
            if (context.mounted) {
              context.push(RoutePaths.profileSignInPath());
            }
          });
        },
        onNotNow: () => Navigator.of(dialogContext).pop(),
      ),
    ),
  );
}

class SignInUnlockPrompt extends StatelessWidget {
  const SignInUnlockPrompt({
    super.key,
    required this.feature,
    required this.onSignIn,
    required this.onNotNow,
  });

  final SignInFeature feature;
  final VoidCallback onSignIn;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.signInUnlockTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            _messageFor(feature),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              FilledButton(
                onPressed: onSignIn,
                child: const Text(AppStrings.signInUnlockSignIn),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onNotNow,
                child: const Text(AppStrings.signInUnlockNotNow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _messageFor(SignInFeature feature) {
  switch (feature) {
    case SignInFeature.bookmarks:
      return AppStrings.signInUnlockBookmarks;
    case SignInFeature.streak:
      return AppStrings.signInUnlockStreak;
    case SignInFeature.personalPrayerList:
      return AppStrings.signInUnlockPersonalPrayerList;
    case SignInFeature.mezmurPlayback:
      return AppStrings.signInUnlockMezmur;
    case SignInFeature.lightCandle:
      return AppStrings.signInUnlockLightCandle;
    case SignInFeature.dailyReflection:
      return AppStrings.signInUnlockDailyReflection;
    case SignInFeature.prayerCompletion:
      return AppStrings.signInUnlockPrayerCompletion;
    case SignInFeature.profile:
      return AppStrings.signInUnlockProfile;
  }
}

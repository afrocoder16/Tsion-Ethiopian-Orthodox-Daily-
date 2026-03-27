import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/data/firebase_account_repository.dart';
import '../auth/models/auth_models.dart';
import '../models/calendar_display_mode.dart';
import 'firebase_providers.dart';

final accountRepositoryProvider = Provider<FirebaseAccountRepository>((ref) {
  return FirebaseAccountRepository(
    bootstrap: ref.watch(firebaseBootstrapProvider),
  );
});

final authSessionProvider = StreamProvider<AuthSession>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  if (!repository.isAvailable) {
    return Stream<AuthSession>.value(
      AuthSession.signedOut(message: repository.unavailableMessage),
    );
  }

  return repository.authStateChanges().asyncMap((_) async {
    try {
      return await repository.loadSession();
    } on AuthRepositoryException catch (error) {
      return AuthSession.error(error.message);
    } catch (error) {
      return AuthSession.error(error.toString());
    }
  });
});

final authActionsControllerProvider =
    NotifierProvider<AuthActionsController, AuthActionState>(
      AuthActionsController.new,
    );

class AuthActionsController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  void clearMessages() {
    state = const AuthActionState();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required CalendarDisplayMode fallbackMode,
  }) async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .signInWithEmail(
            email: email,
            password: password,
            fallbackMode: fallbackMode,
          );
      state = const AuthActionState(successMessage: 'Signed in.');
      return true;
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
      return false;
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .signUpWithEmail(
            displayName: displayName,
            email: email,
            password: password,
            calendarDisplayMode: calendarDisplayMode,
          );
      state = const AuthActionState(successMessage: 'Account created.');
      return true;
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
      return false;
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
      return false;
    }
  }

  Future<bool> signInWithGoogle({
    required CalendarDisplayMode fallbackMode,
  }) async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .signInWithGoogle(fallbackMode: fallbackMode);
      state = const AuthActionState(successMessage: 'Signed in with Google.');
      return true;
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
      return false;
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref.read(accountRepositoryProvider).sendPasswordResetEmail(email);
      state = const AuthActionState(
        successMessage: 'Password reset email sent.',
      );
      return true;
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
      return false;
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref.read(accountRepositoryProvider).signOut();
      state = const AuthActionState(successMessage: 'Signed out.');
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
    }
  }
}

final accountProfileControllerProvider =
    NotifierProvider<AccountProfileController, AuthActionState>(
      AccountProfileController.new,
    );

class AccountProfileController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  Future<bool> updateProfile({
    required String displayName,
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    state = const AuthActionState(isLoading: true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .updateProfile(
            displayName: displayName,
            calendarDisplayMode: calendarDisplayMode,
          );
      ref.invalidate(authSessionProvider);
      state = const AuthActionState(successMessage: 'Profile updated.');
      return true;
    } on AuthRepositoryException catch (error) {
      state = AuthActionState(errorMessage: error.message);
      return false;
    } catch (error) {
      state = AuthActionState(errorMessage: _friendlyAuthError(error));
      return false;
    }
  }

  Future<bool> updateCalendarDisplayMode(
    CalendarDisplayMode calendarDisplayMode,
  ) async {
    try {
      await ref
          .read(accountRepositoryProvider)
          .updateCalendarDisplayMode(calendarDisplayMode);
      ref.invalidate(authSessionProvider);
      return true;
    } on AuthRepositoryException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

String _friendlyAuthError(Object error) {
  if (error is StateError) {
    return error.message;
  }
  final raw = error.toString();
  if (!raw.startsWith('[firebase_auth/')) {
    return raw;
  }

  if (raw.contains('invalid-credential')) {
    return 'The email or password is incorrect.';
  }
  if (raw.contains('email-already-in-use')) {
    return 'That email address is already in use.';
  }
  if (raw.contains('weak-password')) {
    return 'Choose a stronger password.';
  }
  if (raw.contains('network-request-failed')) {
    return 'Network request failed. Check your connection and try again.';
  }
  if (raw.contains('popup-closed-by-user')) {
    return 'Google sign-in was cancelled.';
  }
  if (raw.contains('user-not-found')) {
    return 'No account was found for that email.';
  }
  if (raw.contains('too-many-requests')) {
    return 'Too many attempts. Please wait and try again.';
  }
  return raw;
}

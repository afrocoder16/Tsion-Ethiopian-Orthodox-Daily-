import '../../models/calendar_display_mode.dart';

enum AuthStatus { signedOut, loading, signedIn, error }

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isAnonymous,
    required this.providers,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final List<String> providers;
}

class AccountPreferences {
  const AccountPreferences({required this.calendarDisplayMode});

  final CalendarDisplayMode calendarDisplayMode;

  AccountPreferences copyWith({CalendarDisplayMode? calendarDisplayMode}) {
    return AccountPreferences(
      calendarDisplayMode: calendarDisplayMode ?? this.calendarDisplayMode,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.status,
    this.user,
    this.preferences,
    this.message,
  });

  final AuthStatus status;
  final AuthUser? user;
  final AccountPreferences? preferences;
  final String? message;

  bool get isSignedIn => status == AuthStatus.signedIn && user != null;

  factory AuthSession.signedOut({String? message}) {
    return AuthSession(status: AuthStatus.signedOut, message: message);
  }

  factory AuthSession.loading() {
    return const AuthSession(status: AuthStatus.loading);
  }

  factory AuthSession.signedIn({
    required AuthUser user,
    required AccountPreferences preferences,
  }) {
    return AuthSession(
      status: AuthStatus.signedIn,
      user: user,
      preferences: preferences,
    );
  }

  factory AuthSession.error(String message) {
    return AuthSession(status: AuthStatus.error, message: message);
  }
}

class AuthActionState {
  const AuthActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AuthActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

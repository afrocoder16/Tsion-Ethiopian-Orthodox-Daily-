import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/models/auth_models.dart';
import '../models/calendar_display_mode.dart';
import 'auth_providers.dart';

export '../models/calendar_display_mode.dart';

final calendarDisplayModeProvider =
    NotifierProvider<CalendarDisplayModeNotifier, CalendarDisplayMode>(
      CalendarDisplayModeNotifier.new,
    );

class CalendarDisplayModeNotifier extends Notifier<CalendarDisplayMode> {
  static const _prefsKey = 'calendar_display_mode';

  @override
  CalendarDisplayMode build() {
    ref.listen<AsyncValue<AuthSession>>(authSessionProvider, (previous, next) {
      final previousSession = previous?.asData?.value;
      final nextSession = next.asData?.value;
      if (nextSession?.isSignedIn == true && nextSession?.preferences != null) {
        state = nextSession!.preferences!.calendarDisplayMode;
        return;
      }

      if (previousSession?.isSignedIn == true &&
          nextSession?.isSignedIn != true) {
        _restore();
      }
    });
    _restore();
    return CalendarDisplayMode.ethiopian;
  }

  void setMode(CalendarDisplayMode mode) {
    if (state == mode) {
      return;
    }
    final previous = state;
    state = mode;
    final session = ref.read(authSessionProvider).asData?.value;
    if (session?.isSignedIn == true) {
      unawaited(_persistForSignedInUser(mode, previous));
      return;
    }
    unawaited(_persist(mode));
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    state = calendarDisplayModeFromStorage(saved);
  }

  Future<void> _persist(CalendarDisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.storageValue);
  }

  Future<void> _persistForSignedInUser(
    CalendarDisplayMode next,
    CalendarDisplayMode previous,
  ) async {
    final didPersist = await ref
        .read(accountProfileControllerProvider.notifier)
        .updateCalendarDisplayMode(next);
    if (!didPersist) {
      state = previous;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/calendar_preferences_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionValue = ref.watch(authSessionProvider);
    final authActions = ref.watch(authActionsControllerProvider);
    final calendarMode = ref.watch(calendarDisplayModeProvider);
    final session = sessionValue.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileHero(),
          const SizedBox(height: 16),
          if (sessionValue.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (session?.isSignedIn == true)
            _SignedInSection(
              displayName: session!.user?.displayName ?? 'Tsion User',
              email: session.user?.email ?? 'No email on file',
              providers: session.user?.providers ?? const <String>[],
              mode:
                  session.preferences?.calendarDisplayMode ??
                  CalendarDisplayMode.ethiopian,
              onEdit: () => context.push(RoutePaths.profileEditPath()),
              onSignOut: authActions.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(authActionsControllerProvider.notifier)
                          .signOut();
                    },
            )
          else
            _SignedOutSection(
              message: session?.message,
              onSignIn: () => context.push(RoutePaths.profileSignInPath()),
              onSignUp: () => context.push(RoutePaths.profileSignUpPath()),
              onGoogleSignIn: authActions.isLoading
                  ? null
                  : () async {
                      final didSignIn = await ref
                          .read(authActionsControllerProvider.notifier)
                          .signInWithGoogle(fallbackMode: calendarMode);
                      if (didSignIn && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signed in with Google'),
                          ),
                        );
                      }
                    },
            ),
          const SizedBox(height: 16),
          if (authActions.errorMessage != null)
            _InlineMessage(
              text: authActions.errorMessage!,
              backgroundColor: const Color(0xFFFDECEC),
              foregroundColor: const Color(0xFF7A1F1F),
            ),
          if (authActions.successMessage != null)
            _InlineMessage(
              text: authActions.successMessage!,
              backgroundColor: const Color(0xFFEAF7EC),
              foregroundColor: const Color(0xFF1B5E20),
            ),
          const SizedBox(height: 16),
          _SettingsSection(
            onPreferences: () =>
                context.push(RoutePaths.profilePreferencesPath()),
            onPrayerReminders: () =>
                context.push(RoutePaths.profilePrayerRemindersPath()),
            onNotifications: () =>
                context.push(RoutePaths.profileNotificationsPath()),
          ),
          const SizedBox(height: 16),
          const _ScopeNote(),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Sign in to keep a profile, use Google or email, and store your calendar mode on your account.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SignedOutSection extends StatelessWidget {
  const _SignedOutSection({
    required this.message,
    required this.onSignIn,
    required this.onSignUp,
    required this.onGoogleSignIn,
  });

  final String? message;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback? onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in is optional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'Browse the app without an account, or sign in to set up your profile.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onSignIn, child: const Text('Sign In')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSignUp,
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onGoogleSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInSection extends StatelessWidget {
  const _SignedInSection({
    required this.displayName,
    required this.email,
    required this.providers,
    required this.mode,
    required this.onEdit,
    required this.onSignOut,
  });

  final String displayName;
  final String email;
  final List<String> providers;
  final CalendarDisplayMode mode;
  final VoidCallback onEdit;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(
                    displayName.isEmpty
                        ? 'T'
                        : displayName.substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Providers', value: providers.join(', ')),
            _InfoRow(
              label: 'Calendar mode',
              value: mode == CalendarDisplayMode.ethiopian
                  ? 'Ethiopian'
                  : 'Gregorian',
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onEdit, child: const Text('Edit Profile')),
            const SizedBox(height: 8),
            TextButton(onPressed: onSignOut, child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ScopeNote extends StatelessWidget {
  const _ScopeNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: const Text(
        'Profile now includes app preferences, reminder times, and notification controls. Bookmarks, reading progress, and streaks still stay local.',
        style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.onPreferences,
    required this.onPrayerReminders,
    required this.onNotifications,
  });

  final VoidCallback onPreferences;
  final VoidCallback onPrayerReminders;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.tune,
          title: 'App Preferences',
          subtitle:
              'Choose your default calendar display and feast calculation mode.',
          onTap: onPreferences,
        ),
        _SettingsTile(
          icon: Icons.schedule,
          title: 'Prayer Reminders',
          subtitle: 'Adjust morning, noon, evening, and night prayer times.',
          onTap: onPrayerReminders,
        ),
        _SettingsTile(
          icon: Icons.notifications_none,
          title: 'Notification Center',
          subtitle:
              'Turn daily readings, daily wisdom, feast alerts, and other notifications on or off.',
          onTap: onNotifications,
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: foregroundColor)),
    );
  }
}

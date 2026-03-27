import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/profile/profile_settings.dart';
import '../../../core/providers/profile_settings_providers.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationCenterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Center')),
      body: notificationsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Turn notification categories on or off for the types of messages you want from the app.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            _NotificationTile(
              title: 'Daily readings',
              subtitle: 'Morning reading prompts and scripture reminders.',
              value: settings.dailyReadings,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(dailyReadings: value)),
            ),
            _NotificationTile(
              title: 'Daily wisdom',
              subtitle: 'Short reflections, wisdom notes, and encouragement.',
              value: settings.dailyWisdom,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(dailyWisdom: value)),
            ),
            _NotificationTile(
              title: 'Feast day alerts',
              subtitle: 'Important feast and observance alerts.',
              value: settings.feastDayAlerts,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(feastDayAlerts: value)),
            ),
            _NotificationTile(
              title: 'Prayer reminders',
              subtitle:
                  'Scheduled prayer notifications from your reminder slots.',
              value: settings.prayerReminders,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(prayerReminders: value)),
            ),
            _NotificationTile(
              title: 'Other notifications',
              subtitle: 'General updates and future app announcements.',
              value: settings.generalAnnouncements,
              onChanged: (value) =>
                  _save(ref, settings.copyWith(generalAnnouncements: value)),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load: $error')),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, NotificationCenterSettings settings) {
    return ref.read(notificationCenterProvider.notifier).save(settings);
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

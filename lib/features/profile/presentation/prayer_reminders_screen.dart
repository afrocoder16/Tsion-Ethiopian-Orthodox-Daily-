import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/profile/profile_settings.dart';
import '../../../core/providers/profile_settings_providers.dart';

class PrayerRemindersScreen extends ConsumerWidget {
  const PrayerRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(prayerRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Reminders')),
      body: remindersAsync.when(
        data: (slots) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Adjust reminder times for morning, noon, evening, and night prayer moments.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            ...slots.map(
              (slot) => _ReminderCard(
                slot: slot,
                onChanged: (next) async {
                  await ref
                      .read(prayerRemindersProvider.notifier)
                      .saveSlot(next);
                },
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load: $error')),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.slot, required this.onChanged});

  final PrayerReminderSlot slot;
  final ValueChanged<PrayerReminderSlot> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(slot.timeOfDay),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: slot.isEnabled,
                  onChanged: (value) =>
                      onChanged(slot.copyWith(isEnabled: value)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: slot.timeOfDay,
                  );
                  if (picked == null) {
                    return;
                  }
                  onChanged(slot.copyWith(timeLocal: _serializeTime(picked)));
                },
                child: const Text('Adjust time'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _serializeTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/providers/prayer_flow_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/repos/prayer_flow_repositories.dart';
import '../../../core/providers/streak_providers.dart';
import '../../../core/streak/streak_tasks.dart';

class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({
    super.key,
    required this.prayerId,
  });

  final String prayerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerDetailProvider(prayerId));
    return state.when(
      data: (detail) => _PrayerDetailContent(detail: detail),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load prayer'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(prayerDetailProvider(prayerId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerDetailContent extends ConsumerWidget {
  const _PrayerDetailContent({required this.detail});

  final PrayerDetailState detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.title),
        actions: [
          IconButton(
            onPressed: () async {
              await toggleSave(
                db: ref.read(dbProvider),
                id: detail.id,
                title: detail.title,
                kind: 'prayer',
                createdAtIso: DateTime.now().toIso8601String(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
              }
            },
            icon: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            detail.stillnessTitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            detail.stillnessBody,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),
          const Text(
            'Prayer Text',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            detail.body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Text(
                'Audio',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Switch(value: false, onChanged: null),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final dateYmd = _formatYmd(now);
              await completePrayer(
                db: ref.read(dbProvider),
                dateYmd: dateYmd,
                slotId: detail.slotId,
                completedAtIso: now.toIso8601String(),
              );
              await completeStreakTask(
                db: ref.read(dbProvider),
                dateYmd: dateYmd,
                taskId: streakTaskPrayer,
                completedAtIso: now.toIso8601String(),
              );
              ref.invalidate(prayersScreenStateProvider);
              ref.invalidate(streakScreenProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prayer offered')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Prayer Offered / Amen',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

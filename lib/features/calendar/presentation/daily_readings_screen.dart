import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/providers/streak_providers.dart';
import '../../../core/streak/streak_tasks.dart';

class DailyReadingsScreen extends ConsumerWidget {
  const DailyReadingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarScreenStateProvider);
    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (raw) =>
              _DailyReadingsContent(view: CalendarAdapter(raw).dailyReadings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Unable to load readings')),
        ),
      ),
    );
  }
}

class _DailyReadingsContent extends ConsumerWidget {
  const _DailyReadingsContent({required this.view});

  final DailyReadingsView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epistle = _pickEpistle(view);
    final gospel = _pickGospel(view);
    final otherReadings = _remainingReadings(view, epistle, gospel);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Daily Readings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3EE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4DDD1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Bible rhythm',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                view.isLoaded
                    ? 'Read the appointed passages for the day.'
                    : view.fallbackText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
              if (!view.isLoaded && view.downloadLabel != null) ...[
                const SizedBox(height: 10),
                Text(
                  view.downloadLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReadingCard(
          title: 'Epistle',
          reference: epistle ?? 'Reading will appear here once loaded.',
          icon: Icons.menu_book_rounded,
        ),
        const SizedBox(height: 12),
        _ReadingCard(
          title: 'Today\'s Gospel',
          reference: gospel ?? 'Gospel reading will appear here once loaded.',
          icon: Icons.auto_stories_rounded,
        ),
        if (otherReadings.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'More Readings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          ...otherReadings.map(
            (reading) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReadingListTile(reference: reading),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            await completeStreakTask(
              db: ref.read(dbProvider),
              dateYmd: _formatYmd(now),
              taskId: streakTaskReadings,
              completedAtIso: now.toIso8601String(),
            );
            ref.invalidate(streakScreenProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily readings completed')),
              );
            }
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Mark Readings Complete'),
        ),
      ],
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.title,
    required this.reference,
    required this.icon,
  });

  final String title;
  final String reference;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reference,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingListTile extends StatelessWidget {
  const _ReadingListTile({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        reference,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

String? _pickEpistle(DailyReadingsView view) {
  if (view.liturgy.isNotEmpty) {
    return view.liturgy.first;
  }
  if (view.morning.isNotEmpty) {
    return view.morning.first;
  }
  return null;
}

String? _pickGospel(DailyReadingsView view) {
  if (view.liturgy.length > 1) {
    return view.liturgy[1];
  }
  if (view.evening.isNotEmpty) {
    return view.evening.first;
  }
  if (view.liturgy.isNotEmpty) {
    return view.liturgy.first;
  }
  return null;
}

List<String> _remainingReadings(
  DailyReadingsView view,
  String? epistle,
  String? gospel,
) {
  final values = <String>[...view.morning, ...view.liturgy, ...view.evening];
  final remaining = <String>[];
  var epistleSkipped = false;
  var gospelSkipped = false;
  for (final value in values) {
    if (!epistleSkipped && epistle != null && value == epistle) {
      epistleSkipped = true;
      continue;
    }
    if (!gospelSkipped && gospel != null && value == gospel) {
      gospelSkipped = true;
      continue;
    }
    if (!remaining.contains(value)) {
      remaining.add(value);
    }
  }
  return remaining;
}

String _formatYmd(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

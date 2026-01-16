import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adapters/streak_adapters.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/streak_providers.dart';
import '../../../core/actions/user_actions.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(streakScreenProvider);
    return state.when(
      data: (screen) => _StreakContent(adapter: StreakAdapter(screen)),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load streaks'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(streakScreenProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakContent extends ConsumerWidget {
  const _StreakContent({required this.adapter});

  final StreakAdapter adapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.local_fire_department, size: 18),
            SizedBox(width: 6),
            Text('Streak'),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.info_outline),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(adapter: adapter),
          const SizedBox(height: 18),
          _WeekProgress(adapter: adapter),
          const SizedBox(height: 16),
          _SocialCard(
            title: adapter.socialTitle,
            subtitle: adapter.socialSubtitle,
          ),
          const SizedBox(height: 22),
          _PracticeHeader(
            title: adapter.practiceTitle,
            progressText: adapter.practiceProgressText,
          ),
          const SizedBox(height: 12),
          _PracticeGrid(
            items: adapter.practiceItems,
            onToggle: (item) async {
              final now = DateTime.now();
              final dateYmd = _formatYmd(now);
              await toggleStreakTask(
                db: ref.read(dbProvider),
                dateYmd: dateYmd,
                taskId: item.id,
                completedAtIso: now.toIso8601String(),
              );
              ref.invalidate(streakScreenProvider);
            },
            onNavigate: (item) {
              final path = item.routePath;
              if (path != null) {
                context.go(path);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.adapter});

  final StreakAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                adapter.dayLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                adapter.dateLine,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _ProgressRing(
                progress: adapter.progressValue,
                label: adapter.progressText,
              ),
              const SizedBox(height: 10),
              Text(
                adapter.subtext,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _StreakPill(text: adapter.streakPillText),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: const Color(0xFFE2DDD4),
            color: const Color(0xFFB79C5E),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE8DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WeekProgress extends StatelessWidget {
  const _WeekProgress({required this.adapter});

  final StreakAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                adapter.weekTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                adapter.weekProgressText,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: adapter.weekProgressValue,
            backgroundColor: const Color(0xFFE6E6E6),
            color: const Color(0xFFB79C5E),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: adapter.weekDays
                .map((day) => _WeekChip(day: day))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.day});

  final StreakWeekDayView day;

  @override
  Widget build(BuildContext context) {
    final bgColor = day.isToday
        ? const Color(0xFFE7E0D6)
        : day.isComplete
            ? const Color(0xFFEFE8DD)
            : Colors.white;
    final borderColor = day.isComplete
        ? const Color(0xFFD5C7A8)
        : const Color(0xFFE0E0E0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        day.label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  const _SocialCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E1D7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({required this.title, required this.progressText});

  final String title;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          progressText,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid({
    required this.items,
    required this.onToggle,
    required this.onNavigate,
  });

  final List<StreakPracticeView> items;
  final void Function(StreakPracticeView item) onToggle;
  final void Function(StreakPracticeView item) onNavigate;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (item.routePath == null) {
              onToggle(item);
            } else {
              onNavigate(item);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => onToggle(item),
                    child: _StatusBadge(isDone: item.isDone),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 20, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDone ? const Color(0xFFE7F0E7) : const Color(0xFFF1F1F1);
    final text = isDone ? '[x]' : '[ ]';
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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

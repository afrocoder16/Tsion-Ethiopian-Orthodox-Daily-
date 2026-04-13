import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/streak_adapters.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/providers/streak_providers.dart';
import '../../../core/actions/user_actions.dart';
import '../../calendar/presentation/daily_readings_screen.dart';
import '../../calendar/presentation/synaxarium_screen.dart';
import '../../prayers/presentation/prayer_detail_screen.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(streakScreenProvider);
    return state.when(
      data: (screen) => _StreakContent(adapter: StreakAdapter(screen)),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load streaks'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
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
    final calendarState = ref.watch(calendarScreenStateProvider);
    final saintPreview = calendarState.asData != null
        ? CalendarAdapter(calendarState.asData!.value).saintPreview
        : null;
    final rhythmItems = [
      ...adapter.practiceItems.map(_RhythmCardItem.fromPractice),
      _RhythmCardItem.dailySaint(
        title: saintPreview?.isAvailable == true ? saintPreview!.name : 'Daily Saint',
        subtitle: saintPreview?.isAvailable == true
            ? saintPreview?.summary ?? 'Open today\'s saint'
            : 'Open today\'s saint',
        routePath: RoutePaths.streakSynaxariumPath(_todayYmd()),
      ),
    ];
    final rhythmCompletedCount = adapter.practiceItems.where((item) => item.isDone).length;
    final rhythmTotalCount = rhythmItems.length;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStreakInfoSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            adapter: adapter,
            completedCount: rhythmCompletedCount,
            totalCount: rhythmTotalCount,
          ),
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
            progressText: '$rhythmCompletedCount/$rhythmTotalCount completed',
          ),
          const SizedBox(height: 12),
          _PracticeGrid(
            items: rhythmItems,
            onToggle: (item) async {
              if (item.isDailySaint) {
                return;
              }
              final now = DateTime.now();
              final dateYmd = _formatYmd(now);
              await toggleStreakTask(
                db: ref.read(dbProvider),
                dateYmd: dateYmd,
                taskId: item.id,
                completedAtIso: now.toIso8601String(),
              );
              ref.invalidate(streakScreenProvider);
              ref.invalidate(todayScreenStateProvider);
            },
            onNavigate: (item) {
              _openStreakDestination(context, item);
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.adapter,
    required this.completedCount,
    required this.totalCount,
  });

  final StreakAdapter adapter;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DED0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adapter.dayLabel,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      adapter.dateLine,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StreakPill(text: adapter.streakPillText),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$completedCount/$totalCount',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'completed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: adapter.progressValue,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE7E0D5),
                    color: const Color(0xFFB79C5E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  adapter.subtext,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
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
          const SizedBox(height: 14),
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
        : const Color(0xFFFCFCFB);
    final borderColor = day.isToday || day.isComplete
        ? const Color(0xFFD5C7A8)
        : const Color(0xFFE6E0D8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        day.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: day.isToday || day.isComplete
              ? const Color(0xFF6E5428)
              : Colors.black87,
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
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
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
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

  final List<_RhythmCardItem> items;
  final void Function(_RhythmCardItem item) onToggle;
  final void Function(_RhythmCardItem item) onNavigate;

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8E1D8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: item.isDailySaint
                      ? const _SaintBadge()
                      : GestureDetector(
                          onTap: () => onToggle(item),
                          child: _StatusBadge(isDone: item.isDone),
                        ),
                ),
                const Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.isDone
                        ? const Color(0xFF8B6A2F)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RhythmCardItem {
  const _RhythmCardItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.isDone,
    required this.routePath,
    required this.isDailySaint,
    this.subtitle,
  });

  factory _RhythmCardItem.fromPractice(StreakPracticeView item) {
    return _RhythmCardItem(
      id: item.id,
      title: item.title,
      icon: item.icon,
      isDone: item.isDone,
      routePath: item.routePath,
      isDailySaint: false,
    );
  }

  factory _RhythmCardItem.dailySaint({
    required String title,
    required String subtitle,
    required String routePath,
  }) {
    return _RhythmCardItem(
      id: 'daily-saint',
      title: title,
      subtitle: subtitle,
      icon: Icons.auto_stories,
      isDone: false,
      routePath: routePath,
      isDailySaint: true,
    );
  }

  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isDone;
  final String? routePath;
  final bool isDailySaint;
}

class _SaintBadge extends StatelessWidget {
  const _SaintBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8DF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'SAINT',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Color(0xFF7B5F2A),
        ),
      ),
    );
  }
}

void _showStreakInfoSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D0C3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Why Daily Practice Matters',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Steady faith over rare intensity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'In the Orthodox life, consistency softens the heart. A small prayer said every day opens the soul to God\'s grace more deeply than rare, intense effort.',
                style: TextStyle(fontSize: 16, height: 1.55),
              ),
              const SizedBox(height: 14),
              const Text(
                'Daily practice anchors you in repentance, gratitude, Scripture, and remembrance of Christ amid the noise of the day.',
                style: TextStyle(fontSize: 16, height: 1.55),
              ),
              const SizedBox(height: 14),
              const Text(
                'This rhythm is here to support a humble spiritual routine: simple prayers, daily readings, and small faithful steps that bring you back to God.',
                style: TextStyle(fontSize: 16, height: 1.55),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Little by little, the soul is renewed. “By your endurance you will gain your lives.”',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: Color(0xFF7B5F2A),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _todayYmd() {
  final now = DateTime.now();
  final year = now.year.toString().padLeft(4, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFB79C5E) : const Color(0xFFF6F3EE),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? const Color(0xFFB79C5E) : const Color(0xFFE3DBCF),
        ),
      ),
      child: Icon(
        isDone ? Icons.check : Icons.circle_outlined,
        size: isDone ? 18 : 14,
        color: isDone ? Colors.black : Colors.black38,
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

void _openStreakDestination(BuildContext context, _RhythmCardItem item) {
  Widget? page;
  switch (item.id) {
    case 'daily-prayer':
      page = const PrayerDetailScreen(prayerId: 'prayer-midday');
      break;
    case 'daily-readings':
      page = const DailyReadingsScreen();
      break;
    case 'daily-saint':
      page = SynaxariumScreen(dateKey: _todayYmd());
      break;
  }

  if (page != null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page!),
    );
    return;
  }

  final path = item.routePath;
  if (path != null) {
    context.push(path);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/actions/user_actions.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/adapters/streak_adapters.dart';
import '../../../core/icons/icon_registry.dart';
import '../../../core/providers/calendar_preferences_provider.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/providers/streak_providers.dart';
import '../../../core/streak/streak_tasks.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final now = DateTime.now();
      await completeStreakTask(
        db: ref.read(dbProvider),
        dateYmd: _formatYmd(now),
        taskId: streakTaskDailyVerse,
        completedAtIso: now.toIso8601String(),
      );
      ref.invalidate(streakScreenProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(todayScreenStateProvider);
    final body = screenState.when(
      data: (state) => _TodayContent(adapter: TodayAdapter(state)),
      loading: () => const _TodayLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load today.',
        onRetry: () => ref.refresh(todayScreenStateProvider),
      ),
    );
    return Scaffold(body: SafeArea(child: body));
  }
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent({required this.adapter});

  final TodayAdapter adapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = adapter.header;
    final streakState = ref.watch(streakScreenProvider);
    final calendarMode = ref.watch(calendarDisplayModeProvider);
    final calendarState = ref.watch(calendarScreenStateProvider);
    final now = DateTime.now();
    final weekday = _weekdayName(now.weekday);
    final fallbackGregorianDate =
        '${_monthShortName(now.month)} ${now.day}, ${now.year}';
    final calendarStatus = calendarState.asData == null
        ? null
        : CalendarAdapter(calendarState.asData!.value).status;
    final selectedDateRaw = calendarMode == CalendarDisplayMode.ethiopian
        ? (calendarStatus?.ethiopianDate ?? fallbackGregorianDate)
        : (calendarStatus?.gregorianDate ?? fallbackGregorianDate);
    final selectedDate = calendarMode == CalendarDisplayMode.ethiopian
        ? _normalizeEthiopianDate(selectedDateRaw)
        : _normalizeGregorianDate(selectedDateRaw);
    final greetingLine = '${header.greeting} $weekday - $selectedDate';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    greetingLine,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 170,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: header.actions
                      .map(
                        (action) => _IconRowButton(
                          icon: action.icon,
                          onPressed: action.iconKey == iconKeyStreak
                              ? () => context.push(RoutePaths.streak)
                              : action.iconKey == iconKeyAudio
                              ? () => context.go(RoutePaths.mezmurPath())
                              : action.iconKey == iconKeyInfo
                              ? () => context.go(RoutePaths.reflectionPath())
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _VerseCard(
          view: adapter.verseCard,
          onTap: () => context.push(RoutePaths.streakDailyVerse),
        ),
        const SizedBox(height: 16),
        _AudioCard(view: adapter.audioCard),
        const SizedBox(height: 12),
        streakState.when(
          data: (state) => _DailyDevotionCard(
            adapter: StreakAdapter(state),
            onTap: () => context.push(RoutePaths.streak),
          ),
          loading: () => const _DailyDevotionLoadingCard(),
          error: (error, stackTrace) => _DailyDevotionFallbackCard(
            onTap: () => context.push(RoutePaths.streak),
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(view: adapter.orthodoxDailyHeader),
        const SizedBox(height: 12),
        _Carousel(
          items: adapter.orthodoxDailyItems,
          onTap: (item) => _handleCarouselTap(context, item),
        ),
        const SizedBox(height: 24),
        _SectionHeader(view: adapter.studyWorshipHeader),
        const SizedBox(height: 12),
        _Carousel(
          items: adapter.studyWorshipItems,
          onTap: (item) => _handleCarouselTap(context, item),
        ),
      ],
    );
  }
}

String _weekdayName(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[(weekday - 1).clamp(0, days.length - 1)];
}

String _monthShortName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[(month - 1).clamp(0, months.length - 1)];
}

String _normalizeEthiopianDate(String value) {
  return value
      .replaceAll(RegExp(r'\s*E\.C\.?', caseSensitive: false), '')
      .trim();
}

String _normalizeGregorianDate(String value) {
  return value.trim();
}

void _handleCarouselTap(BuildContext context, TodayCarouselView item) {
  if (item.id == 'today-carousel-mezmur') {
    context.go(RoutePaths.mezmurPath());
    return;
  }
  if (item.id == 'today-carousel-light-candle') {
    context.go(RoutePaths.lightCandlePath());
    return;
  }
  if (item.id == 'today-carousel-feasts-fasts') {
    context.go(RoutePaths.calendarFastingPath());
    return;
  }
  if (item.id == 'today-carousel-daily-readings') {
    context.go(RoutePaths.calendarReadingsPath());
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('${item.title} is not wired yet')));
}

class _TodayLoading extends StatelessWidget {
  const _TodayLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SkeletonLine(width: 120, height: 18),
        const SizedBox(height: 8),
        const _SkeletonLine(width: 160, height: 12),
        const SizedBox(height: 4),
        const _SkeletonLine(width: 140, height: 10),
        const SizedBox(height: 2),
        const _SkeletonLine(width: 110, height: 10),
        const SizedBox(height: 16),
        const _SkeletonBox(height: 180),
        const SizedBox(height: 16),
        const _SkeletonBox(height: 90),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 44),
        const SizedBox(height: 24),
        const _SkeletonLine(width: 140, height: 12),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 168),
        const SizedBox(height: 24),
        const _SkeletonLine(width: 140, height: 12),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 168),
      ],
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2B8B5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFB00020)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 12)),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconRowButton extends StatelessWidget {
  const _IconRowButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: IconButton(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 20),
        splashRadius: 18,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.view, required this.onTap});

  final VerseCardView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3EE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    view.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_stories, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                view.reference,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Container(width: 28, height: 2, color: Colors.black12),
              const SizedBox(height: 10),
              Text(
                view.body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          view.ctaLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (view.isPreviewTruncated)
                    const Text(
                      'Preview',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AudioCard extends StatelessWidget {
  const _AudioCard({required this.view});

  final AudioCardView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E6E1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  view.subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  view.durationText,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Icon(Icons.play_circle_fill, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyDevotionCard extends StatelessWidget {
  const _DailyDevotionCard({required this.adapter, required this.onTap});

  final StreakAdapter adapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewItems = adapter.practiceItems.take(2).toList();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4DBCF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE8DD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: Color(0xFF8E6B2F),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Devotion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        adapter.subtext,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                        fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _DevotionStatChip(
                  label: adapter.streakPillText,
                  background: const Color(0xFFEFE8DD),
                ),
                const SizedBox(width: 8),
                _DevotionStatChip(
                  label: adapter.progressText.toLowerCase(),
                  background: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'This Week',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        adapter.weekProgressText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: adapter.weekProgressValue,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8E3DA),
                      color: const Color(0xFFB79C5E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: adapter.weekDays
                        .take(7)
                        .map((day) => Expanded(child: _MiniWeekChip(day: day)))
                        .toList(),
                  ),
                ],
              ),
            ),
            if (previewItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: previewItems
                    .map((item) => _TaskPreviewPill(item: item))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DailyDevotionLoadingCard extends StatelessWidget {
  const _DailyDevotionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonLine(width: 160, height: 16),
          SizedBox(height: 8),
          _SkeletonLine(width: 180, height: 11),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 28)),
              SizedBox(width: 8),
              Expanded(child: _SkeletonBox(height: 28)),
            ],
          ),
          SizedBox(height: 12),
          _SkeletonBox(height: 72),
        ],
      ),
    );
  }
}

class _DailyDevotionFallbackCard extends StatelessWidget {
  const _DailyDevotionFallbackCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4DBCF)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 22,
              color: Color(0xFF8E6B2F),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Devotion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Open your devotion progress and continue your streak.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _DevotionStatChip extends StatelessWidget {
  const _DevotionStatChip({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MiniWeekChip extends StatelessWidget {
  const _MiniWeekChip({required this.day});

  final StreakWeekDayView day;

  @override
  Widget build(BuildContext context) {
    final background = day.isToday
        ? const Color(0xFFE7E0D6)
        : day.isComplete
        ? const Color(0xFFF4EEE3)
        : Colors.transparent;
    final foreground = day.isToday || day.isComplete
        ? const Color(0xFF7E5E2A)
        : Colors.black45;
    return Container(
      height: 28,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: day.isToday || day.isComplete
              ? const Color(0xFFDCCBA6)
              : const Color(0xFFE8E0D4),
        ),
      ),
      child: Center(
        child: Text(
          day.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _TaskPreviewPill extends StatelessWidget {
  const _TaskPreviewPill({required this.item});

  final StreakPracticeView item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6DED3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 15,
            color: item.isDone ? const Color(0xFF7E5E2A) : Colors.black45,
          ),
          const SizedBox(width: 6),
          Text(
            item.title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Icon(
            item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: item.isDone ? const Color(0xFF7E5E2A) : Colors.black38,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.view});

  final SectionHeaderView view;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          view.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        if (view.showSeeAll)
          Text(
            view.seeAllLabel,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.items, required this.onTap});

  final List<TodayCarouselView> items;
  final void Function(TodayCarouselView item) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _CarouselCard(item: item, onTap: () => onTap(item));
        },
      ),
    );
  }
}

// ignore: unused_element
class _FastingGuidanceSection extends StatelessWidget {
  const _FastingGuidanceSection({required this.view, required this.onTap});

  final FastingGuidanceView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3DBCF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fastfood, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    view.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
            if (view.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                view.subtitle!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            ...view.bullets
                .take(2)
                .map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $bullet',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item, required this.onTap});

  final TodayCarouselView item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
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

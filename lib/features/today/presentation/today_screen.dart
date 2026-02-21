import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/icons/icon_registry.dart';
import '../../../core/providers/screen_state_providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final calendarState = ref.watch(calendarScreenStateProvider);
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
                    header.greeting,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    header.dateText,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    header.calendarLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
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
        _VerseCard(view: adapter.verseCard),
        const SizedBox(height: 16),
        _AudioCard(view: adapter.audioCard),
        const SizedBox(height: 12),
        _MemoryCue(text: adapter.memoryCueText),
        const SizedBox(height: 12),
        calendarState.when(
          data: (state) => _FastingGuidanceSection(
            view: CalendarAdapter(state).fastingGuidance,
            onTap: () => context.go(RoutePaths.calendarFastingPath()),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
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
  const _VerseCard({required this.view});

  final VerseCardView view;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(view.body, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: view.stats
                .map(
                  (stat) => Padding(
                    padding: EdgeInsets.only(
                      right: stat == view.stats.last ? 0 : 16,
                    ),
                    child: _ActionStat(icon: stat.icon, label: stat.label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionStat extends StatelessWidget {
  const _ActionStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
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

class _MemoryCue extends StatelessWidget {
  const _MemoryCue({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

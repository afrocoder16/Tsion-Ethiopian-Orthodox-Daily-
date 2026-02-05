import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/prayer_flow_providers.dart';
import '../../../core/providers/screen_state_providers.dart';

class PrayersScreen extends ConsumerWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(prayersScreenStateProvider);
    final body = screenState.when(
      data: (state) => _PrayersContent(adapter: PrayersAdapter(state)),
      loading: () => const _PrayersLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load prayers.',
        onRetry: () => ref.refresh(prayersScreenStateProvider),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: body,
      ),
    );
  }
}

class _PrayersContent extends ConsumerWidget {
  const _PrayersContent({required this.adapter});

  final PrayersAdapter adapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TopBar(
          title: adapter.topBarTitle,
          streakActive: adapter.streakActive,
          icons: adapter.topBarIcons,
        ),
        const SizedBox(height: 18),
        _PrimaryPrayerCard(
          label: adapter.primaryLabel,
          title: adapter.primaryTitle,
          subtitle: adapter.primarySubtitle,
          actionLabel: adapter.primaryActionLabel,
          onTap: () {
            context.go(RoutePaths.prayerDetailPath(adapter.primaryPrayerId));
          },
        ),
        const SizedBox(height: 18),
        const _QuietDivider(),
        const SizedBox(height: 16),
        _SectionTitle(title: adapter.mezmurHeader.title),
        const SizedBox(height: 12),
        _DevotionalGrid(
          items: adapter.mezmurItems,
          onTap: (item) {
            if (item.id == 'devotional-mezmur') {
              context.go(RoutePaths.mezmurPath());
            }
          },
        ),
        const SizedBox(height: 18),
        _SectionTitle(title: adapter.devotionalHeader.title),
        const SizedBox(height: 12),
        _DevotionalGrid(items: adapter.devotionalItems),
        const SizedBox(height: 18),
        _SectionTitle(title: adapter.myPrayersHeader.title),
        const SizedBox(height: 12),
        _PrayerTileRow(
          items: adapter.myPrayers,
          onTap: (item) {
            context.go('${RoutePaths.prayers}/detail/${item.routeId}');
          },
        ),
        const SizedBox(height: 18),
        _SectionTitle(title: adapter.recentHeader.title),
        const SizedBox(height: 8),
        _RecentLine(
          text: adapter.recentText,
          onTap: () {
            final recentId = ref.read(recentPrayerIdProvider).valueOrNull ??
                adapter.primaryPrayerId;
            context.go(RoutePaths.prayerDetailPath(recentId));
          },
        ),
      ],
    );
  }
}

class _PrayersLoading extends StatelessWidget {
  const _PrayersLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonLine(width: 120, height: 16),
        SizedBox(height: 18),
        _SkeletonBox(height: 140),
        SizedBox(height: 18),
        _SkeletonBox(height: 1),
        SizedBox(height: 16),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 120),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 120),
        SizedBox(height: 18),
        _SkeletonLine(width: 120, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 90),
        SizedBox(height: 18),
        _SkeletonLine(width: 100, height: 12),
        SizedBox(height: 8),
        _SkeletonLine(width: 200, height: 10),
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
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.streakActive,
    required this.icons,
  });

  final String title;
  final bool streakActive;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        _IconButton(
          icon: icons.isNotEmpty ? icons.first : Icons.headphones,
          onTap: () => context.go(RoutePaths.mezmurPath()),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => context.push(RoutePaths.streak),
          child: _StreakIcon(isActive: streakActive),
        ),
        if (icons.length > 1) _IconButton(icon: icons[1]),
        if (icons.length > 2) _IconButton(icon: icons[2]),
      ],
    );
  }
}

class _StreakIcon extends StatelessWidget {
  const _StreakIcon({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF6F3EE) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(
        Icons.local_fire_department,
        size: 16,
        color: isActive ? Colors.black87 : Colors.black26,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: Colors.black54),
        ),
      ),
    );
  }
}

class _PrimaryPrayerCard extends StatelessWidget {
  const _PrimaryPrayerCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String label;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietDivider extends StatelessWidget {
  const _QuietDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFE6E6E6),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: Colors.black54,
      ),
    );
  }
}

class _DevotionalGrid extends StatelessWidget {
  const _DevotionalGrid({required this.items, this.onTap});

  final List<DevotionalItemView> items;
  final void Function(DevotionalItemView item)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => InkWell(
              onTap: onTap == null ? null : () => onTap!(item),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 18, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PrayerTileRow extends StatelessWidget {
  const _PrayerTileRow({required this.items, required this.onTap});

  final List<PrayerTileView> items;
  final void Function(PrayerTileView item) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => GestureDetector(
              onTap: () => onTap(item),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
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

class _RecentLine extends StatelessWidget {
  const _RecentLine({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }
}

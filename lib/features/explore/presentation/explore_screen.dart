import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../app/route_paths.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(exploreScreenStateProvider);
    final body = screenState.when(
      data: (state) => _ExploreContent(adapter: ExploreAdapter(state)),
      loading: () => const _ExploreLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load explore.',
        onRetry: () => ref.refresh(exploreScreenStateProvider),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: body,
      ),
    );
  }
}

class _ExploreContent extends StatelessWidget {
  const _ExploreContent({required this.adapter});

  final ExploreAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TopBar(
          title: adapter.topBarTitle,
          subtitle: adapter.topBarSubtitle,
          icons: adapter.topBarIcons,
        ),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.studyHeader),
        const SizedBox(height: 12),
        _HorizontalCards(
          items: adapter.studyItems,
          onTap: (item) => context.go(
            RoutePaths.exploreItemPath(item.routeId),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.guidedHeader),
        const SizedBox(height: 10),
        _SmallTileRow(
          items: adapter.guidedPaths,
          onTap: (item) => context.go(
            RoutePaths.explorePathPath(item.routeId),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.communityHeader),
        const SizedBox(height: 10),
        _SmallTileRow(
          items: adapter.communityItems,
          onTap: (item) => context.go(
            RoutePaths.exploreCommunityPath(item.routeId),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.categoriesHeader),
        const SizedBox(height: 10),
        _CategoryChips(items: adapter.categories),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.contentHeader),
        const SizedBox(height: 10),
        _ContentGrid(items: adapter.contentItems),
        const SizedBox(height: 18),
        _SectionTitle(view: adapter.savedHeader),
        const SizedBox(height: 10),
        _SavedContainer(
          child: adapter.savedItems.isEmpty
              ? const _EmptyState(label: 'No saved items yet')
              : _SavedList(
                  items: adapter.savedItems,
                  icon: adapter.savedIcon,
                  onTap: (item) => context.go(
                    RoutePaths.exploreItemPath(item.id),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ExploreLoading extends StatelessWidget {
  const _ExploreLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonLine(width: 140, height: 16),
        SizedBox(height: 18),
        _SkeletonLine(width: 200, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 170),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 10),
        _SkeletonBox(height: 80),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 10),
        _SkeletonBox(height: 80),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 10),
        _SkeletonBox(height: 36),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 10),
        _SkeletonBox(height: 190),
        SizedBox(height: 18),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 10),
        _SkeletonBox(height: 100),
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
    required this.subtitle,
    required this.icons,
  });

  final String title;
  final String subtitle;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
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
          ],
        ),
        const Spacer(),
        if (icons.isNotEmpty) _IconButton(icon: icons.first),
        if (icons.length > 1) _IconButton(icon: icons[1]),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.view});

  final SectionHeaderView view;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          view.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (view.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            view.subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}

class _HorizontalCards extends StatelessWidget {
  const _HorizontalCards({required this.items, this.onTap});

  final List<ExploreCardView> items;
  final void Function(ExploreCardView item)? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: onTap == null ? null : () => onTap!(item),
            child: _ExploreCard(item: item),
          );
        },
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item});

  final ExploreCardView item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
          const SizedBox(height: 10),
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
    );
  }
}

class _SmallTileRow extends StatelessWidget {
  const _SmallTileRow({required this.items, this.onTap});

  final List<SmallTileView> items;
  final void Function(SmallTileView item)? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(item),
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.items});

  final List<CategoryChipView> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: label.isSelected ? const Color(0xFFE7E0D6) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: label.isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContentGrid extends StatelessWidget {
  const _ContentGrid({required this.items});

  final List<ExploreContentView> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ContentCard(item: item);
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item});

  final ExploreContentView item;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return GestureDetector(
          onTap: () => context.go(
            RoutePaths.exploreItemPath(item.routeId),
          ),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    onPressed: () async {
                      await toggleSave(
                        db: ref.read(dbProvider),
                        id: item.routeId,
                        title: item.title,
                        kind: 'explore',
                        createdAtIso: DateTime.now().toIso8601String(),
                      );
                      ref.invalidate(exploreScreenStateProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved')),
                        );
                      }
                    },
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

class _SavedList extends StatelessWidget {
  const _SavedList({
    required this.items,
    required this.icon,
    required this.onTap,
  });

  final List<SavedItemView> items;
  final IconData icon;
  final void Function(SavedItemView item) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: InkWell(
                onTap: () => onTap(item),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: Colors.black54),
                    const SizedBox(width: 10),
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
            ),
          )
          .toList(),
    );
  }
}

class _SavedContainer extends StatelessWidget {
  const _SavedContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
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

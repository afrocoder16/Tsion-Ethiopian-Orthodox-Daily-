import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(booksScreenStateProvider);
    final body = screenState.when(
      data: (state) => _BooksContent(adapter: BooksAdapter(state)),
      loading: () => const _BooksLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load books.',
        onRetry: () => ref.refresh(booksScreenStateProvider),
      ),
    );
    return Scaffold(body: SafeArea(child: body));
  }
}

class _BooksContent extends StatelessWidget {
  const _BooksContent({required this.adapter});

  final BooksAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final filters = adapter.filterChips;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SearchBar(placeholder: adapter.searchPlaceholder),
        const SizedBox(height: 10),
        Row(
          children: [
            const _FilterButton(),
            const SizedBox(width: 10),
            Expanded(child: _FilterChips(filters: filters)),
          ],
        ),
        const SizedBox(height: 22),
        _SectionHeader(view: adapter.continueReadingHeader),
        const SizedBox(height: 12),
        _ContinueReadingShelf(
          items: adapter.continueReadingItems,
          actionLabel: adapter.continueReadingActionLabel,
          onTap: (item) {
            context.go(RoutePaths.bookReaderPath(item.routeId));
          },
        ),
        const SizedBox(height: 22),
        _SectionHeader(view: adapter.saintsHeader),
        const SizedBox(height: 12),
        _PatronSaintCard(
          view: adapter.patronSaint,
          onTap: () => context.push(
            RoutePaths.patronSaintPath(adapter.patronSaint.name),
          ),
        ),
        const SizedBox(height: 12),
        _SectionBlock(
          isMuted: adapter.isBibleSelected,
          child: _HorizontalShelf(
            items: adapter.saintsShelf.take(3).toList(),
            onTap: (item) {
              context.go(RoutePaths.bookDetailPath(item.routeId));
            },
          ),
        ),
        const SizedBox(height: 22),
        _SectionGroupTitle(title: adapter.libraryHeader.title),
        const SizedBox(height: 12),
        _SectionBlock(
          isMuted: adapter.isSaintsSelected,
          child: _HorizontalShelf(
            items: adapter.bibleShelf.take(3).toList(),
            onTap: (item) {
              if (item.isBible) {
                context.go(RoutePaths.bibleLibraryPath());
              } else {
                context.go(RoutePaths.bookDetailPath(item.routeId));
              }
            },
          ),
        ),
        const SizedBox(height: 28),
        const _SoftDivider(),
        const SizedBox(height: 24),
        _SectionGroupTitle(title: adapter.orthodoxBooksHeader.title),
        const SizedBox(height: 12),
        _SectionBlock(
          isMuted: !adapter.isAllSelected,
          child: _BooksGrid(
            items: adapter.orthodoxBooks,
            onTap: (item) {
              context.go(RoutePaths.bookDetailPath(item.routeId));
            },
          ),
        ),
      ],
    );
  }
}

class _BooksLoading extends StatelessWidget {
  const _BooksLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonBox(height: 48),
        SizedBox(height: 12),
        _SkeletonBox(height: 36),
        SizedBox(height: 22),
        _SkeletonLine(width: 160, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 170),
        SizedBox(height: 22),
        _SkeletonLine(width: 100, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 90),
        SizedBox(height: 12),
        _SkeletonBox(height: 150),
        SizedBox(height: 28),
        _SkeletonBox(height: 1),
        SizedBox(height: 24),
        _SkeletonLine(width: 140, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 220),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.placeholder});

  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Colors.black45),
          const SizedBox(width: 8),
          Text(
            placeholder,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.tune, size: 18, color: Colors.black54),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filters});

  final List<BooksFilterChipView> filters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index].label;
          final isSelected = filters[index].isSelected;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE7E0D6) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          );
        },
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                view.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              if (view.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  view.subtitle!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
        if (view.showSeeAll)
          Text(
            view.seeAllLabel,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
      ],
    );
  }
}

class _HorizontalShelf extends StatelessWidget {
  const _HorizontalShelf({required this.items, this.onTap});

  final List<BookItemView> items;
  final void Function(BookItemView item)? onTap;

  static const double _itemWidth = 110;
  static const double _itemHeight = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final card = _BookCover(
            title: item.title,
            subtitle: null,
            width: _itemWidth,
          );
          return onTap == null
              ? card
              : GestureDetector(onTap: () => onTap!(item), child: card);
        },
      ),
    );
  }
}

class _ContinueReadingShelf extends StatelessWidget {
  const _ContinueReadingShelf({
    required this.items,
    required this.actionLabel,
    required this.onTap,
  });

  final List<BookItemView> items;
  final String actionLabel;
  final void Function(BookItemView item) onTap;

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
            onTap: () => onTap(item),
            child: _ContinueReadingCard(item: item, actionLabel: actionLabel),
          );
        },
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.item, required this.actionLabel});

  final BookItemView item;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              item.subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, this.subtitle, required this.width});

  final String title;
  final String? subtitle;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({required this.items, required this.onTap});

  final List<BookItemView> items;
  final void Function(BookItemView item) onTap;

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
          onTap: () => onTap(item),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionGroupTitle extends StatelessWidget {
  const _SectionGroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.black54,
      ),
    );
  }
}

class _PatronSaintCard extends StatelessWidget {
  const _PatronSaintCard({required this.view, this.onTap});

  final PatronSaintView view;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7DD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              view.label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              view.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFE5E5E5));
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.child, this.isMuted = false});

  final Widget child;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: isMuted ? 0.4 : 1, child: child);
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

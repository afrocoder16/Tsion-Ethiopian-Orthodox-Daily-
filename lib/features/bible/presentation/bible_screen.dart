import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const selectedFilter = _BooksFilter.all;

    final continueReading = [
      const _BookItem('Psalm 23', subtitle: 'Last chapter: Verse 4'),
      const _BookItem('Gospel of Matthew', subtitle: 'Last chapter: 5'),
      const _BookItem('Life of St. Mary', subtitle: 'Last chapter: 2'),
    ];

    final bibleShelf = [
      const _BookItem('Bible'),
      const _BookItem('Audio Bible'),
      const _BookItem('Reading Plan'),
    ];

    final saintsShelf = [
      const _BookItem('Synaxarium'),
      const _BookItem('Lives of Saints'),
      const _BookItem('Daily Saint'),
    ];

    final orthodoxBooks = [
      const _BookItem('The Divine Liturgy'),
      const _BookItem('The Ladder'),
      const _BookItem('On Prayer'),
      const _BookItem('Sayings of the Desert Fathers'),
      const _BookItem('The Philokalia'),
      const _BookItem('Lives of the Saints'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: const [
                _ReadingStreakBadge(compact: true),
                SizedBox(width: 12),
                Expanded(child: _SearchBar()),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const _FilterButton(),
                const SizedBox(width: 10),
                Expanded(child: _FilterChips(selected: selectedFilter)),
              ],
            ),
            const SizedBox(height: 22),
            const _SectionHeader(
              title: 'Continue Reading',
              subtitle: 'Continue where you left off',
            ),
            const SizedBox(height: 12),
            _ContinueReadingShelf(
              items: continueReading,
              onTap: (item) {
                final id = _bookIdFromTitle(item.title);
                context.go(RoutePaths.bookReaderPath(id));
              },
            ),
            const SizedBox(height: 22),
            _SectionHeader(title: 'Saints', showSeeAll: true),
            const SizedBox(height: 12),
            const _PatronSaintCard(name: 'Athon'),
            const SizedBox(height: 12),
            _SectionBlock(
              isMuted: selectedFilter == _BooksFilter.bible,
              child: _HorizontalShelf(
                items: saintsShelf.take(3).toList(),
                onTap: (item) {
                  final id = _bookIdFromTitle(item.title);
                  context.go(RoutePaths.bookDetailPath(id));
                },
              ),
            ),
            const SizedBox(height: 22),
            const _SectionGroupTitle(title: 'LIBRARY'),
            const SizedBox(height: 12),
            _SectionBlock(
              isMuted: selectedFilter == _BooksFilter.saints,
              child: _HorizontalShelf(
                items: bibleShelf.take(3).toList(),
                onTap: (item) {
                  if (item.title == 'Bible') {
                    context.go(RoutePaths.bibleLibraryPath());
                  } else {
                    final id = _bookIdFromTitle(item.title);
                    context.go(RoutePaths.bookDetailPath(id));
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
            const _SoftDivider(),
            const SizedBox(height: 24),
            const _SectionGroupTitle(title: 'ORTHODOX BOOKS'),
            const SizedBox(height: 12),
            _SectionBlock(
              isMuted: selectedFilter != _BooksFilter.all,
              child: _BooksGrid(
                items: orthodoxBooks,
                onTap: (item) {
                  final id = _bookIdFromTitle(item.title);
                  context.go(RoutePaths.bookDetailPath(id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

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
        children: const [
          Icon(Icons.search, size: 20, color: Colors.black45),
          SizedBox(width: 8),
          Text(
            'Search by title',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
            ),
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

class _ReadingStreakBadge extends StatelessWidget {
  const _ReadingStreakBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.local_fire_department, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            '7-day reading streak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BooksFilter { all, bible, saints, prayers, teachings, history }

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected});

  final _BooksFilter selected;

  @override
  Widget build(BuildContext context) {
    const labels = [
      _FilterLabel('All', _BooksFilter.all),
      _FilterLabel('Bible', _BooksFilter.bible),
      _FilterLabel('Saints', _BooksFilter.saints),
      _FilterLabel('Prayers', _BooksFilter.prayers),
      _FilterLabel('Teachings', _BooksFilter.teachings),
      _FilterLabel('History', _BooksFilter.history),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = labels[index].text;
          final isSelected = labels[index].value == selected;
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
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.showSeeAll = false,
  });

  final String title;
  final String? subtitle;
  final bool showSeeAll;

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
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showSeeAll)
          const Text(
            'See all',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }
}

class _BookItem {
  const _BookItem(this.title, {this.subtitle});

  final String title;
  final String? subtitle;
}

class _HorizontalShelf extends StatelessWidget {
  const _HorizontalShelf({
    required this.items,
    this.itemWidth = 110,
    this.itemHeight = 150,
    this.showSubtitle = false,
    this.onTap,
  });

  final List<_BookItem> items;
  final double itemWidth;
  final double itemHeight;
  final bool showSubtitle;
  final void Function(_BookItem item)? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final card = _BookCover(
            title: item.title,
            subtitle: showSubtitle ? item.subtitle : null,
            width: itemWidth,
          );
          return onTap == null
              ? card
              : GestureDetector(
                  onTap: () => onTap!(item),
                  child: card,
                );
        },
      ),
    );
  }
}

class _ContinueReadingShelf extends StatelessWidget {
  const _ContinueReadingShelf({
    required this.items,
    required this.onTap,
  });

  final List<_BookItem> items;
  final void Function(_BookItem item) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onTap(item),
            child: _ContinueReadingCard(item: item),
          );
        },
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.item});

  final _BookItem item;

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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              item.subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Resume',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.title,
    this.subtitle,
    required this.width,
  });

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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({
    required this.items,
    required this.onTap,
  });

  final List<_BookItem> items;
  final void Function(_BookItem item) onTap;

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
  const _PatronSaintCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7DD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Patron Saint',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFE5E5E5),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.child, this.isMuted = false});

  final Widget child;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isMuted ? 0.4 : 1,
      child: child,
    );
  }
}

class _FilterLabel {
  const _FilterLabel(this.text, this.value);

  final String text;
  final _BooksFilter value;
}

String _bookIdFromTitle(String title) {
  return title.toLowerCase().replaceAll(' ', '-');
}

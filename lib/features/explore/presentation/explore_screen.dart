import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const studyItems = [
      _ExploreCardItem(
        title: 'Mistere Beta Kristiyan',
        subtitle: 'Foundations of the faith',
      ),
      _ExploreCardItem(
        title: 'Life in the Church',
        subtitle: 'Worship and community',
      ),
      _ExploreCardItem(
        title: 'Sacraments of the Church',
        subtitle: 'Mysteries and grace',
      ),
    ];

    const guidedPaths = [
      _SmallTile('New to Orthodoxy'),
      _SmallTile('Understanding the Liturgy'),
      _SmallTile('Living the Fast'),
    ];

    const communityItems = [
      _SmallTile('Ask a Question'),
      _SmallTile('Read Reflections'),
      _SmallTile('Community Prayers'),
    ];

    const categories = [
      'All',
      'Life in Christ',
      'Prayer & Worship',
      'Saints',
      'Fasting',
      'Theology',
    ];

    const contentItems = [
      _ExploreContentItem(
        title: 'Learning the Hours',
        category: 'Prayer & Worship',
      ),
      _ExploreContentItem(
        title: 'Saints of the Desert',
        category: 'Saints',
      ),
      _ExploreContentItem(
        title: 'The Gospel Readings',
        category: 'Life in Christ',
      ),
    ];

    const savedItems = [
      _SavedItem('Faith & Tradition'),
      _SavedItem('Understanding the Liturgy'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TopBar(),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Sunbit Timhert Bet',
              subtitle: 'Structured Orthodox learning from trusted books and teachings.',
            ),
            const SizedBox(height: 12),
            _HorizontalCards(items: studyItems),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Guided Paths',
              subtitle: 'Step-by-step learning journeys.',
            ),
            const SizedBox(height: 10),
            _SmallTileRow(items: guidedPaths),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Community',
              subtitle: 'Quiet Orthodox community space.',
            ),
            const SizedBox(height: 10),
            _SmallTileRow(items: communityItems),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Explore Categories'),
            const SizedBox(height: 10),
            _CategoryChips(items: categories),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Explore Content'),
            const SizedBox(height: 10),
            _ContentRow(items: contentItems),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Saved Content'),
            const SizedBox(height: 10),
            _SavedContainer(child: _SavedList(items: savedItems)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'EXPLORE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Learn, study, and grow in the Orthodox faith',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const Spacer(),
        _IconButton(icon: Icons.calendar_today),
        _IconButton(icon: Icons.person),
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
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
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
    );
  }
}

class _ExploreCardItem {
  const _ExploreCardItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class _HorizontalCards extends StatelessWidget {
  const _HorizontalCards({required this.items});

  final List<_ExploreCardItem> items;

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
          return _ExploreCard(item: item);
        },
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item});

  final _ExploreCardItem item;

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

class _SmallTile {
  const _SmallTile(this.title);

  final String title;
}

class _SmallTileRow extends StatelessWidget {
  const _SmallTileRow({required this.items});

  final List<_SmallTile> items;

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
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = items[index];
          final isSelected = index == 0;
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

class _ExploreContentItem {
  const _ExploreContentItem({
    required this.title,
    required this.category,
  });

  final String title;
  final String category;
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.items});

  final List<_ExploreContentItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ContentCard(item: item);
        },
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item});

  final _ExploreContentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
    );
  }
}

class _SavedItem {
  const _SavedItem(this.title);

  final String title;
}

class _SavedList extends StatelessWidget {
  const _SavedList({required this.items});

  final List<_SavedItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, size: 18, color: Colors.black54),
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

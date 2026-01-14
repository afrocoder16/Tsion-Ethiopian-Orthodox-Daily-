import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const verseTitle = 'Verse of the Day';
    const verseRef = 'John 11:25';
    const verseBody =
        'Jesus said to her, "I am the resurrection and the life. Whoever '
        'believes in me, though he die, yet shall he live."';

    const carouselOneItems = [
      _TodayCarouselItem('Midday Prayer', 'Short guided prayer'),
      _TodayCarouselItem('Daily Readings', 'Lectionary selections'),
      _TodayCarouselItem('Feasts & Fasts', 'Today in the calendar'),
      _TodayCarouselItem('Today\'s Saint', 'Life and remembrance'),
      _TodayCarouselItem('Daily Tip', 'Small step for today'),
      _TodayCarouselItem('Ask a Question', 'Learn the faith'),
    ];

    const carouselTwoItems = [
      _TodayCarouselItem('Orthodox Music', 'Chants and hymns'),
      _TodayCarouselItem('Light a Candle', 'Offer a prayer'),
      _TodayCarouselItem('Find Your Church', 'Nearby parishes'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Bless you',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monday - January 12',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Julian | Ethiopian',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _IconRowButton(icon: Icons.headphones),
                _IconRowButton(icon: Icons.favorite),
                _IconRowButton(icon: Icons.local_fire_department),
                _IconRowButton(icon: Icons.trending_up),
                _IconRowButton(icon: Icons.calendar_today),
                _IconRowButton(icon: Icons.person),
              ],
            ),
            const SizedBox(height: 16),
            _VerseCard(
              title: verseTitle,
              reference: verseRef,
              body: verseBody,
            ),
            const SizedBox(height: 16),
            const _AudioCard(),
            const SizedBox(height: 12),
            const _MemoryCue(),
            const SizedBox(height: 24),
            _SectionHeader(title: 'ORTHODOX DAILY', showSeeAll: true),
            const SizedBox(height: 12),
            _Carousel(items: carouselOneItems),
            const SizedBox(height: 24),
            _SectionHeader(title: 'STUDY & WORSHIP', showSeeAll: false),
            const SizedBox(height: 12),
            _Carousel(items: carouselTwoItems),
          ],
        ),
      ),
    );
  }
}

class _IconRowButton extends StatelessWidget {
  const _IconRowButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 20),
        splashRadius: 18,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.title,
    required this.reference,
    required this.body,
  });

  final String title;
  final String reference;
  final String body;

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
                title,
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
            reference,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 28,
            height: 2,
            color: Colors.black12,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _ActionStat(icon: Icons.menu_book, label: '124'),
              SizedBox(width: 16),
              _ActionStat(icon: Icons.favorite_border, label: '38'),
              SizedBox(width: 16),
              _ActionStat(icon: Icons.share, label: '12'),
            ],
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
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _AudioCard extends StatelessWidget {
  const _AudioCard();

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
              children: const [
                Text(
                  'Hear Today\'s Word',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Today\'s Reading',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '9:24 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
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
  const _MemoryCue();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.bookmark, size: 18, color: Colors.black54),
          SizedBox(width: 8),
          Text(
            'Continue Reading',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.showSeeAll});

  final String title;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        if (showSeeAll)
          Text(
            'See all',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}

class _TodayCarouselItem {
  const _TodayCarouselItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.items});

  final List<_TodayCarouselItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _CarouselCard(item: item);
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item});

  final _TodayCarouselItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

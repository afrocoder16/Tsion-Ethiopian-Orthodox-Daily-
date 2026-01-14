import 'package:flutter/material.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rhythmItems = [
      _RhythmItem('Morning', Icons.wb_sunny_outlined),
      _RhythmItem('Midday', Icons.wb_sunny),
      _RhythmItem('Evening', Icons.nights_stay_outlined),
      _RhythmItem('Night', Icons.dark_mode_outlined),
    ];

    const devotionalItems = [
      _DevotionalItem(
        title: 'Light a Candle',
        subtitle: 'Offer a prayer in silence',
        icon: Icons.local_fire_department,
      ),
      _DevotionalItem(
        title: 'Daily Reflection',
        subtitle: 'A quiet question for the heart',
        icon: Icons.self_improvement,
      ),
      _DevotionalItem(
        title: 'Mezmur (Orthodox Music)',
        subtitle: 'Chants and hymns for prayer',
        icon: Icons.library_music,
      ),
    ];

    const myPrayers = [
      _PrayerTile('Trisagion Prayers'),
      _PrayerTile('Psalm 50'),
      _PrayerTile('Prayer of St. Ephrem'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TopBar(),
            const SizedBox(height: 18),
            const _PrimaryPrayerCard(),
            const SizedBox(height: 18),
            const _QuietDivider(),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'DAILY RHYTHM'),
            const SizedBox(height: 12),
            _RhythmRow(items: rhythmItems),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'DEVOTIONAL ACTIONS'),
            const SizedBox(height: 12),
            _DevotionalGrid(items: devotionalItems),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'MY PRAYERS'),
            const SizedBox(height: 12),
            _PrayerTileRow(items: myPrayers),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'RECENT'),
            const SizedBox(height: 8),
            const _RecentLine(text: 'Last prayed: Midday Prayer - Today'),
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
      children: [
        const _StreakIcon(isActive: true),
        const SizedBox(width: 10),
        const Text(
          'PRAYERS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        _IconButton(icon: Icons.library_music),
        _IconButton(icon: Icons.calendar_today),
        _IconButton(icon: Icons.person),
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
  const _IconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
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

class _PrimaryPrayerCard extends StatelessWidget {
  const _PrimaryPrayerCard();

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
          const Text(
            'Prayer for This Moment',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Midday Prayer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'The prayer appointed for this hour',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Begin Prayer',
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

class _RhythmItem {
  const _RhythmItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _RhythmRow extends StatelessWidget {
  const _RhythmRow({required this.items});

  final List<_RhythmItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isCurrent = item.label == 'Midday';
        return Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFF6F3EE) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DevotionalItem {
  const _DevotionalItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _DevotionalGrid extends StatelessWidget {
  const _DevotionalGrid({required this.items});

  final List<_DevotionalItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
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
          )
          .toList(),
    );
  }
}

class _PrayerTile {
  const _PrayerTile(this.title);

  final String title;
}

class _PrayerTileRow extends StatelessWidget {
  const _PrayerTileRow({required this.items});

  final List<_PrayerTile> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => Container(
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
          )
          .toList(),
    );
  }
}

class _RecentLine extends StatelessWidget {
  const _RecentLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black54,
      ),
    );
  }
}

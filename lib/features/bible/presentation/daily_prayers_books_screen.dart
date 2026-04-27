import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';

class DailyPrayersBooksScreen extends StatelessWidget {
  const DailyPrayersBooksScreen({super.key});

  static const _books = <_PrayerBookItem>[
    _PrayerBookItem(
      id: 'book-wudase-mariyam',
      title: 'Wudase Mariyam',
      subtitle: 'Daily praise of Saint Mary',
    ),
    _PrayerBookItem(
      id: 'book-psalms',
      title: 'Psalms',
      subtitle: 'Psalms for daily devotion',
    ),
    _PrayerBookItem(
      id: 'book-sene-gologota',
      title: 'Sene Gologota',
      subtitle: 'Passion prayers and meditations',
    ),
    _PrayerBookItem(
      id: 'book-seyfe-selase',
      title: 'Seyfe Selase',
      subtitle: 'Trinitarian prayer collection',
    ),
    _PrayerBookItem(
      id: 'book-seyfe-melekot',
      title: 'Seyfe Melekot',
      subtitle: 'Prayer book of heavenly mysteries',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Prayers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _books.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _books[index];
          return InkWell(
            onTap: () => context.go(RoutePaths.bookDetailPath(item.id)),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6E2DA)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDE6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PrayerBookItem {
  const _PrayerBookItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

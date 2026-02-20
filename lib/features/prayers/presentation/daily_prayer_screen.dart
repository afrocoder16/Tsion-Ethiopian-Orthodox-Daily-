import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';

class DailyPrayerScreen extends StatelessWidget {
  const DailyPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F4),
        elevation: 0,
        title: const Text('Daily Prayer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Choose a time of day',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _PrayerSlotCard(
              title: 'Morning Prayer',
              subtitle: 'Start the day in prayer',
              onTap: () => context.go(
                RoutePaths.prayerDetailPath('prayer-morning'),
              ),
            ),
            _PrayerSlotCard(
              title: 'Midday Prayer',
              subtitle: 'The prayer appointed for this hour',
              onTap: () => context.go(
                RoutePaths.prayerDetailPath('prayer-midday'),
              ),
            ),
            _PrayerSlotCard(
              title: 'Afternoon Prayer',
              subtitle: 'Quiet remembrance at mid-afternoon',
              onTap: () => context.go(
                RoutePaths.prayerDetailPath('prayer-afternoon'),
              ),
            ),
            _PrayerSlotCard(
              title: 'Night Prayer',
              subtitle: 'Close the day in peace',
              onTap: () => context.go(
                RoutePaths.prayerDetailPath('prayer-night'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerSlotCard extends StatelessWidget {
  const _PrayerSlotCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                child: const Icon(Icons.wb_twilight, color: Colors.black45),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
      ),
    );
  }
}

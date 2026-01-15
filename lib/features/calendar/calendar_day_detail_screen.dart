import 'package:flutter/material.dart';

class CalendarDayDetailScreen extends StatelessWidget {
  const CalendarDayDetailScreen({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Day $date')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ethiopian Date',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gregorian Date',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          const Text(
            'December 13',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bahire Hasab',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Daily signals and seasonal meaning for this day in the church '
            'calendar. This block will include the computed values and their '
            'interpretation.',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          const Text(
            'Links',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const _LinkTile(label: 'Readings'),
          const _LinkTile(label: 'Saint'),
          const _LinkTile(label: 'Prayers'),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrayerDetailScreen extends StatelessWidget {
  const PrayerDetailScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Opening stillness',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a moment of silence before prayer.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),
          const Text(
            'Prayer Text',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a placeholder prayer body. It will be replaced with the '
            'full text for the selected prayer, scrollable and readable.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Text(
                'Audio',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Switch(value: false, onChanged: null),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Prayer Offered / Amen',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

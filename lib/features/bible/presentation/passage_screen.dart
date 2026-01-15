import 'package:flutter/material.dart';

class PassageScreen extends StatelessWidget {
  const PassageScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  final String book;
  final int chapter;

  @override
  Widget build(BuildContext context) {
    final verses = List<int>.generate(6, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('$book $chapter'),
        actions: const [
          _PassageAction(icon: Icons.bookmark_border),
          _PassageAction(icon: Icons.copy),
          _PassageAction(icon: Icons.share),
          SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: verses
            .map(
              (verse) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '$verse. Placeholder verse text for reading.',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PassageAction extends StatelessWidget {
  const _PassageAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      splashRadius: 18,
    );
  }
}

import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
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
          _ReaderAction(icon: Icons.text_fields),
          _ReaderAction(icon: Icons.palette_outlined),
          _ReaderAction(icon: Icons.bookmark_border),
          _ReaderAction(icon: Icons.sticky_note_2_outlined),
          _ReaderAction(icon: Icons.share),
          SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Chapter 1',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'This is a placeholder reader view. It represents the body text for a '
            'selected book. The final version will render chapters and verses '
            'with adjustable typography and themes.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ReaderAction extends StatelessWidget {
  const _ReaderAction({required this.icon});

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

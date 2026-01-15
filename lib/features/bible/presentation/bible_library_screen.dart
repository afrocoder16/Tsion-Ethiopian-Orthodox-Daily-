import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';

class BibleLibraryScreen extends StatelessWidget {
  const BibleLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const books = [
      'Genesis',
      'Exodus',
      'Psalms',
      'Matthew',
      'John',
      'Romans',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bible Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: books
            .map(
              (book) => _ListTile(
                title: book,
                onTap: () => context.go(RoutePaths.bibleChaptersPath(book)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

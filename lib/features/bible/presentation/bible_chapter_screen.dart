import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';

class BibleChapterScreen extends StatelessWidget {
  const BibleChapterScreen({
    super.key,
    required this.book,
  });

  final String book;

  @override
  Widget build(BuildContext context) {
    final chapters = List<int>.generate(10, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(title: Text(book)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: chapters
            .map(
              (chapter) => _ChapterTile(
                label: 'Chapter $chapter',
                onTap: () => context.go(
                  RoutePaths.biblePassagePath(book, chapter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({required this.label, required this.onTap});

  final String label;
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
              label,
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

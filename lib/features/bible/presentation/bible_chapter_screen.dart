import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/book_flow_providers.dart';

class BibleChapterScreen extends ConsumerWidget {
  const BibleChapterScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bibleChaptersProvider(bookId));
    return book.when(
      data: (item) {
        final chapters = item?.chapters ?? 0;
        final chapterList = chapters == 0
            ? <int>[]
            : List<int>.generate(chapters, (index) => index + 1);
        return Scaffold(
          appBar: AppBar(title: Text(item?.title ?? bookId)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: chapterList
                .map(
                  (chapter) => _ChapterTile(
                    label: 'Chapter $chapter',
                    onTap: () => context.go(
                      RoutePaths.biblePassagePath(bookId, chapter),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load chapters'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(bibleChaptersProvider(bookId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/book_flow_providers.dart';

class BibleLibraryScreen extends ConsumerWidget {
  const BibleLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bibleLibraryProvider);
    return state.when(
      data: (library) => Scaffold(
        appBar: AppBar(title: const Text('Bible Library')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: library.books
              .map(
                (book) => _ListTile(
                  title: book.title,
                  subtitle: '${book.chapters} chapters',
                  onTap: () => context.go(
                    RoutePaths.bibleChaptersPath(book.id),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load Bible library'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(bibleLibraryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

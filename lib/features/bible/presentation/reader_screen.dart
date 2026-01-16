import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/repos/book_flow_repositories.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/providers/repo_providers.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerProvider(bookId));
    return state.when(
      data: (reader) => _ReaderContent(reader: reader),
      loading: () => const _Loading(),
      error: (error, _) => _ErrorCard(
        message: 'Unable to load reader.',
        onRetry: () => ref.refresh(readerProvider(bookId)),
      ),
    );
  }
}

class _ReaderContent extends ConsumerWidget {
  const _ReaderContent({required this.reader});

  final ReaderState reader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = [
      _Control(Icons.text_fields),
      _Control(Icons.brightness_6_outlined),
      _Control(
        Icons.bookmark_border,
        onTap: () async {
          await toggleSave(
            db: ref.read(dbProvider),
            id: 'reader-${reader.bookId}',
            title: reader.bookTitle,
            kind: 'bookmark',
            createdAtIso: DateTime.now().toIso8601String(),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bookmark saved')),
            );
          }
        },
      ),
      _Control(Icons.edit_outlined),
      _Control(
        Icons.share_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Share not implemented')),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${reader.bookTitle} • ${reader.chapterLabel}'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F3EE),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              children: [
                ...controls,
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: reader.content
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        p,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control(this.icon, {this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      splashRadius: 18,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

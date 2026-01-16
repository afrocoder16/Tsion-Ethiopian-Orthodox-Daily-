import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/repos/book_flow_repositories.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/providers/repo_providers.dart';

class PassageScreen extends ConsumerWidget {
  const PassageScreen({
    super.key,
    required this.bookId,
    required this.chapter,
  });

  final String bookId;
  final int chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passageProvider((bookId, chapter)));
    return state.when(
      data: (passage) => _PassageContent(passage: passage),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load passage'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(passageProvider((bookId, chapter))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassageContent extends ConsumerWidget {
  const _PassageContent({required this.passage});

  final PassageState passage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${passage.bookTitle} ${passage.chapter}'),
        actions: [
          _PassageAction(
            icon: Icons.bookmark_border,
            onTap: () async {
              await toggleSave(
                db: ref.read(dbProvider),
                id: 'passage-${passage.bookId}-${passage.chapter}',
                title: '${passage.bookTitle} ${passage.chapter}',
                kind: 'bookmark',
                createdAtIso: DateTime.now().toIso8601String(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmarked')),
                );
              }
            },
          ),
          _PassageAction(
            icon: Icons.copy,
            onTap: () async {
              final text = passage.verses
                  .map((v) => '${v.number}. ${v.text}')
                  .join('\n');
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
          ),
          _PassageAction(
            icon: Icons.share,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share not implemented')),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: passage.verses
            .map(
              (verse) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${verse.number}. ${verse.text}',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _PassageAction extends StatelessWidget {
  const _PassageAction({required this.icon, this.onTap});

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

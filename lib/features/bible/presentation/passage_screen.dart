import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/user_actions.dart';
import '../../../core/auth/sign_in_guard.dart';
import '../../../core/repos/book_flow_repositories.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/providers/repo_providers.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/providers/sync_providers.dart';

class PassageScreen extends ConsumerWidget {
  const PassageScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    this.trackForContinueReading = false,
  });

  final String bookId;
  final int chapter;
  final bool trackForContinueReading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(bibleLangProvider);
    final state = ref.watch(passageProvider((bookId, chapter, lang)));
    return state.when(
      data: (passage) => _PassageContent(
        passage: passage,
        trackForContinueReading: trackForContinueReading,
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load passage'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(passageProvider((bookId, chapter, lang))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassageContent extends ConsumerStatefulWidget {
  const _PassageContent({
    required this.passage,
    required this.trackForContinueReading,
  });

  final PassageState passage;
  final bool trackForContinueReading;

  @override
  ConsumerState<_PassageContent> createState() => _PassageContentState();
}

class _PassageContentState extends ConsumerState<_PassageContent> {
  @override
  void initState() {
    super.initState();
    if (widget.trackForContinueReading) {
      _saveReadingProgress();
    }
  }

  @override
  void didUpdateWidget(covariant _PassageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trackForContinueReading &&
        (oldWidget.passage.bookId != widget.passage.bookId ||
            oldWidget.passage.chapter != widget.passage.chapter ||
            oldWidget.trackForContinueReading !=
                widget.trackForContinueReading)) {
      _saveReadingProgress();
    }
  }

  Future<void> _saveReadingProgress() async {
    await setReadingProgress(
      db: ref.read(dbProvider),
      bookId: widget.passage.bookId,
      lastLocation: 'Chapter ${widget.passage.chapter}',
      progressText: 'Chapter ${widget.passage.chapter}',
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    ref.invalidate(booksScreenStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final passage = widget.passage;
    return Scaffold(
      appBar: AppBar(
        title: Text('${passage.bookTitle} ${passage.chapter}'),
        actions: [
          _PassageAction(
            icon: Icons.bookmark_border,
            onTap: () async {
              await ref
                  .read(signInGuardProvider)
                  .run<void>(
                    context,
                    feature: SignInFeature.bookmarks,
                    action: () async {
                      final sync = await ref.read(
                        userDataSyncServiceProvider.future,
                      );
                      await toggleSave(
                        db: ref.read(dbProvider),
                        id: 'passage-${passage.bookId}-${passage.chapter}',
                        title: '${passage.bookTitle} ${passage.chapter}',
                        kind: 'bookmark',
                        createdAtIso: DateTime.now().toIso8601String(),
                        sync: sync,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bookmarked')),
                        );
                      }
                    },
                  );
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
              (verse) => _VerseTile(
                verse: verse,
                bookTitle: passage.bookTitle,
                chapter: passage.chapter,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({
    required this.verse,
    required this.bookTitle,
    required this.chapter,
  });

  final PassageVerse verse;
  final String bookTitle;
  final int chapter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final text =
            '${verse.number}. ${verse.text} ($bookTitle $chapter:${verse.number})';
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verse ${verse.number} copied'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          '${verse.number}. ${verse.text}',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
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

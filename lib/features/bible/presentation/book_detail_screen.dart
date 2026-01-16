import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/actions/user_actions.dart';
import '../../../core/repos/book_flow_repositories.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/providers/repo_providers.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailProvider(bookId));
    return state.when(
      data: (detail) => _BookDetailContent(detail: detail),
      loading: () => const _Loading(),
      error: (error, _) => _ErrorCard(
        message: 'Unable to load book.',
        onRetry: () => ref.refresh(bookDetailProvider(bookId)),
      ),
    );
  }
}

class _BookDetailContent extends ConsumerWidget {
  const _BookDetailContent({required this.detail});

  final BookDetailState detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(detail.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.menu_book, size: 48, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.author,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PrimaryButton(
                label: 'Start',
                onTap: () async {
                  await setReadingProgress(
                    db: ref.read(dbProvider),
                    bookId: detail.id,
                    lastLocation: 'Chapter 1',
                    progressText: 'Chapter 1',
                    updatedAtIso: DateTime.now().toIso8601String(),
                  );
                  if (context.mounted) {
                    context.go(RoutePaths.bookReaderPath(detail.id));
                  }
                },
              ),
              const SizedBox(width: 10),
              _SecondaryButton(
                label: detail.resumeLabel,
                onTap: () async {
                  await setReadingProgress(
                    db: ref.read(dbProvider),
                    bookId: detail.id,
                    lastLocation: detail.resumeLabel,
                    progressText: detail.resumeLabel,
                    updatedAtIso: DateTime.now().toIso8601String(),
                  );
                  if (context.mounted) {
                    context.go(RoutePaths.bookReaderPath(detail.id));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Badge(
                icon: Icons.download_done,
                label: detail.isDownloaded ? 'Offline' : 'Not downloaded',
              ),
              const SizedBox(width: 10),
              const _Badge(icon: Icons.cloud_download, label: 'Download'),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Table of Contents',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...detail.toc.map((item) => _TocItem(title: item)),
        ],
      ),
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TocItem extends StatelessWidget {
  const _TocItem({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}

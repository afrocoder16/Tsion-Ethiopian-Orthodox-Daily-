import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/content/book_content_store.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/strings/app_strings.dart';

/// Lists the Daily Prayers collection. Books are content-driven: only books
/// with a bundled content pack appear here.
class DailyPrayersBooksScreen extends ConsumerWidget {
  const DailyPrayersBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksState = ref.watch(dailyPrayerBooksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dailyPrayerBooksTitle)),
      body: booksState.when(
        data: (books) => books.isEmpty
            ? const Center(
                child: Text(
                  AppStrings.dailyPrayerBooksEmpty,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: books.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _PrayerBookCard(book: books[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.dailyPrayerBooksError),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(dailyPrayerBooksProvider),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerBookCard extends StatelessWidget {
  const _PrayerBookCard({required this.book});

  final BookContent book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RoutePaths.bookDetailPath(book.id)),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E2DA)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.black45),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

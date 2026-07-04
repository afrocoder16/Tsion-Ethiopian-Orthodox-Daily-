import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/book_flow_providers.dart';
import '../../../core/repos/book_flow_repositories.dart';
import '../../../core/strings/app_strings.dart';

class BibleLibraryScreen extends ConsumerStatefulWidget {
  const BibleLibraryScreen({super.key});

  @override
  ConsumerState<BibleLibraryScreen> createState() => _BibleLibraryScreenState();
}

class _BibleLibraryScreenState extends ConsumerState<BibleLibraryScreen> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bibleLibraryProvider);
    return state.when(
      data: (library) {
        final lang = ref.watch(bibleLangProvider);
        final trimmedQuery = _query.trim();
        final searchState = trimmedQuery.isEmpty
            ? null
            : ref.watch(bibleSearchProvider((trimmedQuery, lang)));

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.bibleLibraryTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BibleSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),
              if (searchState == null)
                ...library.books.map(
                  (book) => _ListTile(
                    title: book.title,
                    subtitle: AppStrings.bibleChaptersCount(book.chapters),
                    onTap: () =>
                        context.go(RoutePaths.bibleChaptersPath(book.id)),
                  ),
                )
              else
                _SearchResults(
                  state: searchState,
                  onTap: (result) => context.go(
                    RoutePaths.biblePassagePath(
                      result.bookId,
                      result.chapter,
                      trackForContinueReading: true,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const _DelayedLoadingScaffold(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.unableToLoadBibleLibrary),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(bibleLibraryProvider),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BibleSearchField extends StatelessWidget {
  const _BibleSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: AppStrings.bibleSearchHint,
          icon: Icon(Icons.search, size: 20, color: Colors.black45),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onTap});

  final AsyncValue<List<BibleSearchResult>> state;
  final void Function(BibleSearchResult result) onTap;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (results) {
        if (results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text(AppStrings.bibleSearchEmpty)),
          );
        }
        return Column(
          children: results
              .map(
                (result) => _ListTile(
                  title:
                      '${result.bookTitle} ${result.chapter}:${result.verse}',
                  subtitle: result.snippet.isNotEmpty
                      ? result.snippet
                      : result.text,
                  onTap: () => onTap(result),
                ),
              )
              .toList(growable: false),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: Text(AppStrings.unableToLoadBibleLibrary)),
      ),
    );
  }
}

class _DelayedLoadingScaffold extends StatefulWidget {
  const _DelayedLoadingScaffold();

  @override
  State<_DelayedLoadingScaffold> createState() =>
      _DelayedLoadingScaffoldState();
}

class _DelayedLoadingScaffoldState extends State<_DelayedLoadingScaffold> {
  bool _showMessage = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showMessage = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (_showMessage) ...[
              const SizedBox(height: 14),
              const Text(AppStrings.biblePreparingLibrary),
            ],
          ],
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
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

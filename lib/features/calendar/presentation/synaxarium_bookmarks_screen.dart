import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/calendar_day_detail_providers.dart';

class SynaxariumBookmarksScreen extends ConsumerStatefulWidget {
  const SynaxariumBookmarksScreen({super.key});

  @override
  ConsumerState<SynaxariumBookmarksScreen> createState() =>
      _SynaxariumBookmarksScreenState();
}

class _SynaxariumBookmarksScreenState
    extends ConsumerState<SynaxariumBookmarksScreen> {
  int _version = 0;

  void _refresh() {
    setState(() {
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(synaxariumBookmarksProvider(_version));
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Synaxarium Days')),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No saved days yet',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: ListTile(
                  onTap: () => context.push(
                    RoutePaths.calendarSynaxariumEntryPath(item.key),
                  ),
                  title: Text(
                    item.primarySaint ?? 'Synaxarium Day',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    item.saints.length > 1
                        ? '${item.key}  •  +${item.saints.length - 1} more'
                        : item.key,
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    onPressed: () async {
                      await ref
                          .read(synaxariumRepositoryProvider)
                          .toggleBookmark(item.key);
                      _refresh();
                    },
                    icon: const Icon(Icons.bookmark_remove_outlined),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: _refresh,
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

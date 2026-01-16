import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/explore_detail_providers.dart';

class ExploreDetailScreen extends ConsumerWidget {
  const ExploreDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exploreDetailProvider(itemId));
    return state.when(
      data: (detail) => Scaffold(
        appBar: AppBar(title: Text(detail.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              detail.category,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              detail.body,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
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
              const Text('Unable to load detail'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(exploreDetailProvider(itemId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

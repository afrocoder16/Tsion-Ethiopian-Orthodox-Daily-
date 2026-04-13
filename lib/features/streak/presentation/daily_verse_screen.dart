import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class DailyVerseScreen extends ConsumerWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todayScreenStateProvider);
    return state.when(
      data: (screen) => _DailyVerseContent(view: TodayAdapter(screen).verseCard),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load daily verse'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(todayScreenStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyVerseContent extends StatelessWidget {
  const _DailyVerseContent({required this.view});

  final VerseCardView view;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Daily Verse'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DBCF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verse of the Day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    view.reference,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 42,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB79C5E),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    view.body,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Carry this verse with you through the day.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

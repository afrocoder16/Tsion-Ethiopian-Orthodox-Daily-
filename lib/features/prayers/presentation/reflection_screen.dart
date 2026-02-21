import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class ReflectionScreen extends ConsumerWidget {
  const ReflectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayersScreenStateProvider);
    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (raw) =>
              _ReflectionContent(view: PrayersAdapter(raw).reflectionJournal),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Unable to load reflection')),
        ),
      ),
    );
  }
}

class _ReflectionContent extends StatelessWidget {
  const _ReflectionContent({required this.view});

  final ReflectionJournalView view;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 4),
            Text(
              view.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3EE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4DDD1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PromptBlock(
                label: 'Gratitude',
                question: view.gratitudeQuestion,
              ),
              const SizedBox(height: 12),
              _PromptBlock(
                label: 'Honest check',
                question: view.honestCheckQuestion,
              ),
              const SizedBox(height: 12),
              _PromptBlock(
                label: 'Small step',
                question: view.smallStepQuestion,
              ),
              const SizedBox(height: 14),
              Text(
                view.closingLine,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptBlock extends StatelessWidget {
  const _PromptBlock({required this.label, required this.question});

  final String label;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E0D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

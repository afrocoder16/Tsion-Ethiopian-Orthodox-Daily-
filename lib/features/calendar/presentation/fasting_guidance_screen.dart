import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class FastingGuidanceScreen extends ConsumerWidget {
  const FastingGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(calendarScreenStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fasting Guidance')),
      body: SafeArea(
        child: screenState.when(
          data: (state) {
            final view = CalendarAdapter(state).fastingGuidance;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [_FastingGuidanceCard(view: view)],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Unable to load fasting guidance')),
        ),
      ),
    );
  }
}

class _FastingGuidanceCard extends StatelessWidget {
  const _FastingGuidanceCard({required this.view});

  final FastingGuidanceView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2DBCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            view.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (view.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              view.subtitle!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 12),
          ...view.bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 8, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (view.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              view.notes!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

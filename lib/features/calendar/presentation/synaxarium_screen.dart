import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/calendar_day_detail_providers.dart';

class SynaxariumScreen extends ConsumerWidget {
  const SynaxariumScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarDayDetailProvider(dateKey));
    return state.when(
      data: (detail) {
        return Scaffold(
          appBar: AppBar(title: const Text('Read Synaxarium')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                detail.ethiopianDate,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (detail.saints.isEmpty)
                const Text(
                  'No saint data yet',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                )
              else
                ...detail.saints.map(
                  (saint) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saint.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          saint.snippet,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Read Synaxarium')),
        body: Center(
          child: FilledButton(
            onPressed: () => ref.refresh(calendarDayDetailProvider(dateKey)),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

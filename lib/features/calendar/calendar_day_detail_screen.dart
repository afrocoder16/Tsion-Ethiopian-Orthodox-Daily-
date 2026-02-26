import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_paths.dart';
import '../../core/adapters/calendar_day_detail_adapter.dart';
import '../../core/providers/calendar_day_detail_providers.dart';
import '../../core/repos/calendar_day_detail_repositories.dart';

class CalendarDayDetailScreen extends ConsumerWidget {
  const CalendarDayDetailScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarDayDetailProvider(dateKey));
    return state.when(
      data: (detail) => _CalendarDayContent(detail: detail),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load day detail'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(calendarDayDetailProvider(dateKey)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDayContent extends StatelessWidget {
  const _CalendarDayContent({required this.detail});

  final CalendarDayDetailState detail;

  @override
  Widget build(BuildContext context) {
    final adapter = CalendarDayDetailAdapter(detail);
    return Scaffold(
      appBar: AppBar(title: Text(adapter.ethiopianDate)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _LabelText(text: 'Ethiopian Date'),
          const SizedBox(height: 6),
          Text(
            adapter.ethiopianDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            adapter.gregorianDate,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            adapter.weekday,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text('Evangelist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _StatChip(label: 'Evangelist', value: adapter.evangelist),
          const SizedBox(height: 20),
          const Text(
            'Celebrations',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (adapter.celebrations.isEmpty)
            const _EmptyLine(text: 'No celebrations yet')
          else
            ...adapter.celebrations.map(
              (item) => _InfoCard(title: item.title, subtitle: item.subtitle),
            ),
          const SizedBox(height: 18),
          const Text(
            'Saints of the Day',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (adapter.saints.isEmpty)
            const _EmptyLine(text: 'No saint data yet')
          else
            ...adapter.saints.map(
              (item) => _InfoCard(
                title: item.name,
                subtitle: item.snippet,
                actionLabel: 'Read Synaxarium',
                onTap: () =>
                    context.push(RoutePaths.calendarSynaxariumPath(detail.dateKey)),
              ),
            ),
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  const _LabelText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B5BA6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Color(0xFF6B5BA6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}

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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
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
          const SizedBox(height: 12),
          const _LabelText(text: 'Gregorian Date'),
          const SizedBox(height: 6),
          Text(
            adapter.gregorianDate,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Text(
            adapter.bahireTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            adapter.bahireDescription,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: adapter.bahireTags
                .map((tag) => _Chip(label: tag))
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          const Text(
            'Observances',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...adapter.observances.map(
            (item) => _ObservanceRow(
              label: item.label,
              value: item.value,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Links',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...adapter.links.map(
            (link) => _LinkTile(
              label: link.label,
              onTap: () => _handleLink(context, detail.dateKey, link),
            ),
          ),
        ],
      ),
    );
  }
}

void _handleLink(BuildContext context, String dateKey, CalendarLink link) {
  switch (link.type) {
    case CalendarLinkType.prayers:
      context.go(RoutePaths.prayers);
      break;
    case CalendarLinkType.readings:
      context.go(RoutePaths.calendarDayLinkPath(dateKey, 'readings'));
      break;
    case CalendarLinkType.saint:
      context.go(RoutePaths.calendarDayLinkPath(dateKey, 'saint'));
      break;
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ObservanceRow extends StatelessWidget {
  const _ObservanceRow({required this.label, required this.value});

  final String label;
  final String value;

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
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

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
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

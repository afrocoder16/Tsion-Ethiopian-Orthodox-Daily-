import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          const Text(
            'Bahire Hasab',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: adapter.bahireStats
                .map((item) => _StatChip(label: item.label, value: item.value))
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          const Text(
            'Today in the Church',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...adapter.observances.map(
            (item) => _ObservanceRow(label: item.label, value: item.value),
          ),
          const SizedBox(height: 18),
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
              (item) => _SaintCard(title: item.name, subtitle: item.snippet),
            ),
          const SizedBox(height: 12),
          const _DailyTodoCard(),
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
      width: (MediaQuery.of(context).size.width - 56) / 3,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
        ],
      ),
    );
  }
}

class _SaintCard extends StatelessWidget {
  const _SaintCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: () {}, child: const Text('Read Saint')),
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

class _DailyTodoCard extends StatefulWidget {
  const _DailyTodoCard();

  @override
  State<_DailyTodoCard> createState() => _DailyTodoCardState();
}

class _DailyTodoCardState extends State<_DailyTodoCard> {
  bool _prayerDone = false;
  bool _readingDone = false;
  bool _mercyDone = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily To-do',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Prayer done', style: TextStyle(fontSize: 13)),
            value: _prayerDone,
            onChanged: (value) => setState(() => _prayerDone = value ?? false),
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Read Scripture', style: TextStyle(fontSize: 13)),
            value: _readingDone,
            onChanged: (value) => setState(() => _readingDone = value ?? false),
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Act of mercy', style: TextStyle(fontSize: 13)),
            value: _mercyDone,
            onChanged: (value) => setState(() => _mercyDone = value ?? false),
          ),
        ],
      ),
    );
  }
}

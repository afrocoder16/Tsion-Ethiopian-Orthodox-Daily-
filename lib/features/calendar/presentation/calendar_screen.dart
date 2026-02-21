import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(calendarScreenStateProvider);
    final body = screenState.when(
      data: (state) => _CalendarContent(adapter: CalendarAdapter(state)),
      loading: () => const _CalendarLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load calendar.',
        onRetry: () => ref.refresh(calendarScreenStateProvider),
      ),
    );
    return Scaffold(body: SafeArea(child: body));
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.adapter});

  final CalendarAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TopBar(
          title: adapter.topBarTitle,
          subtitle: adapter.topBarSubtitle,
          icons: adapter.topBarIcons,
        ),
        const SizedBox(height: 16),
        _MonthSelector(items: adapter.months),
        const SizedBox(height: 16),
        _TodayStatusCard(view: adapter.status),
        const SizedBox(height: 12),
        _SignalsRow(items: adapter.signalChips),
        const SizedBox(height: 16),
        _TodayObservanceCard(
          title: adapter.todayObservanceTitle,
          fastingToday: adapter.fastingToday,
          fastingType: adapter.fastingType,
          reasons: adapter.fastReasons,
          quickRules: adapter.quickRules,
          onTap: () => context.go('${RoutePaths.calendar}/day/${_todayYmd()}'),
        ),
        const SizedBox(height: 12),
        _DailyReadingsCard(view: adapter.dailyReadings),
        const SizedBox(height: 12),
        _SaintPreviewCard(view: adapter.saintPreview),
        const SizedBox(height: 20),
        _SectionTitle(title: adapter.upcomingHeader.title),
        const SizedBox(height: 12),
        _UpcomingList(
          items: adapter.upcomingDays,
          onTap: (item) => context.go('${RoutePaths.calendar}/day/${item.id}'),
        ),
      ],
    );
  }
}

String _todayYmd() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.icons,
  });

  final String title;
  final String subtitle;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        const Spacer(),
        if (icons.isNotEmpty) _IconButton(icon: icons.first),
        if (icons.length > 1) _IconButton(icon: icons[1]),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({required this.view});

  final CalendarStatusView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            view.weekday,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  view.ethiopianDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: view.ethiopianDate),
                  );
                },
                splashRadius: 16,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            ],
          ),
          if (view.ethiopianDateAmharic != null) ...[
            Text(
              view.ethiopianDateAmharic!,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            view.gregorianDate,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _SignalsRow extends StatelessWidget {
  const _SignalsRow({required this.items});

  final List<SignalChipView> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.title}: ${item.value}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayObservanceCard extends StatelessWidget {
  const _TodayObservanceCard({
    required this.title,
    required this.fastingToday,
    required this.fastingType,
    required this.reasons,
    required this.quickRules,
    this.onTap,
  });

  final String title;
  final bool fastingToday;
  final String fastingType;
  final List<String> reasons;
  final List<String> quickRules;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _StatusLine(
            label: 'Fasting today',
            value: fastingToday ? 'Yes' : 'No',
          ),
          _StatusLine(label: 'Type', value: fastingType),
          const SizedBox(height: 8),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('- $reason', style: const TextStyle(fontSize: 12)),
            ),
          ),
          if (quickRules.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...quickRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  rule,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DailyReadingsCard extends StatelessWidget {
  const _DailyReadingsCard({required this.view});

  final DailyReadingsView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Readings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (view.isLoaded) ...[
            _ReadingLine(label: 'Morning', refs: view.morning),
            _ReadingLine(label: 'Liturgy', refs: view.liturgy),
            _ReadingLine(label: 'Evening', refs: view.evening),
          ] else
            Text(
              view.fallbackText,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: () {}, child: Text(view.ctaLabel)),
              if (view.downloadLabel != null)
                OutlinedButton(
                  onPressed: () {},
                  child: Text(view.downloadLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingLine extends StatelessWidget {
  const _ReadingLine({required this.label, required this.refs});

  final String label;
  final List<String> refs;

  @override
  Widget build(BuildContext context) {
    final text = refs.isEmpty ? '-' : refs.join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $text', style: const TextStyle(fontSize: 12)),
    );
  }
}

class _SaintPreviewCard extends StatelessWidget {
  const _SaintPreviewCard({required this.view});

  final SaintPreviewView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saint of the Day',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            view.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            view.summary,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: view.isAvailable ? () {} : null,
            child: Text(view.ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.items, required this.onTap});

  final List<UpcomingDayView> items;
  final void Function(UpcomingDayView item) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => GestureDetector(
              onTap: () => onTap(item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 78,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.ethDate,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle ?? item.saint,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.badges
                          .map(
                            (badge) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE7DD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.items});

  final List<MonthChipView> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: label.isSelected ? const Color(0xFFE7E0D6) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: label.isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalendarLoading extends StatelessWidget {
  const _CalendarLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonLine(width: 140, height: 16),
        SizedBox(height: 16),
        _SkeletonBox(height: 36),
        SizedBox(height: 16),
        _SkeletonBox(height: 100),
        SizedBox(height: 12),
        _SkeletonBox(height: 52),
        SizedBox(height: 16),
        _SkeletonBox(height: 120),
        SizedBox(height: 12),
        _SkeletonBox(height: 110),
        SizedBox(height: 12),
        _SkeletonBox(height: 110),
      ],
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2B8B5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFB00020)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 12)),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

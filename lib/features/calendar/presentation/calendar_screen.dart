import 'package:flutter/material.dart';
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
    return Scaffold(
      body: SafeArea(
        child: body,
      ),
    );
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
        _TodayStatusCard(
          ethiopianDate: adapter.ethiopianDate,
          gregorianDate: adapter.gregorianDate,
        ),
        const SizedBox(height: 12),
        _SignalsRow(items: adapter.signalChips),
        const SizedBox(height: 16),
        _TodayObservanceCard(
          title: adapter.todayObservanceTitle,
          observances: adapter.observances,
          onTap: () => context.go(
            '${RoutePaths.calendar}/day/${adapter.ethiopianDate}',
          ),
        ),
        const SizedBox(height: 12),
        _TodayActionsRow(items: adapter.todayActions),
        const SizedBox(height: 20),
        _SectionTitle(title: adapter.upcomingHeader.title),
        const SizedBox(height: 12),
        _UpcomingList(
          items: adapter.upcomingDays,
          onTap: (item) => context.go(
            '${RoutePaths.calendar}/day/${item.date}',
          ),
        ),
      ],
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
        _SkeletonBox(height: 90),
        SizedBox(height: 12),
        _SkeletonBox(height: 36),
        SizedBox(height: 16),
        _SkeletonBox(height: 90),
        SizedBox(height: 12),
        _SkeletonBox(height: 70),
        SizedBox(height: 20),
        _SkeletonLine(width: 120, height: 12),
        SizedBox(height: 12),
        _SkeletonBox(height: 200),
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
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
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
  const _TodayStatusCard({
    required this.ethiopianDate,
    required this.gregorianDate,
  });

  final String ethiopianDate;
  final String gregorianDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ethiopianDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gregorianDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalsRow extends StatelessWidget {
  const _SignalsRow({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
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
    required this.observances,
    this.onTap,
  });

  final String title;
  final List<ObservanceView> observances;
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...observances.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ObservanceRow(item: item),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(onTap: onTap, child: card);
  }
}

class _ObservanceRow extends StatelessWidget {
  const _ObservanceRow({required this.item});

  final ObservanceView item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          item.labelText,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.valueText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TodayActionsRow extends StatelessWidget {
  const _TodayActionsRow({required this.items});

  final List<CalendarActionView> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      children.add(
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(item.icon, size: 18, color: Colors.black54),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
      if (i < items.length - 1) {
        children.add(const SizedBox(width: 8));
      }
    }
    return Row(children: children);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
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
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.saint,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              color:
                  label.isSelected ? const Color(0xFFE7E0D6) : Colors.white,
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

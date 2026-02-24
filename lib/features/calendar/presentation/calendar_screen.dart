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
        const SizedBox(height: 14),
        _MonthCalendarScroller(
          months: adapter.monthGrids,
          years: adapter.availableYears,
          onDayTap: (dateKey) =>
              context.go('${RoutePaths.calendar}/day/$dateKey'),
        ),
        const SizedBox(height: 12),
        _SaintPreviewCard(
          view: adapter.saintPreview,
          onReadSaint: () =>
              context.go(RoutePaths.calendarSynaxariumPath(_todayYmd())),
        ),
        const SizedBox(height: 12),
        _SpiritualTrackerCard(view: adapter.spiritualTracker),
      ],
    );
  }
}

enum _CalendarViewMode { ethiopian, gregorian }

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.view,
    required this.years,
    required this.onPickYear,
    required this.onGoToToday,
    required this.mode,
    required this.onModeChanged,
    required this.onDayTap,
  });

  final CalendarMonthGridView view;
  final List<int> years;
  final ValueChanged<int> onPickYear;
  final VoidCallback onGoToToday;
  final _CalendarViewMode mode;
  final ValueChanged<_CalendarViewMode> onModeChanged;
  final ValueChanged<String> onDayTap;

  @override
  Widget build(BuildContext context) {
    final isEthiopian = mode == _CalendarViewMode.ethiopian;
    final monthTitle = isEthiopian
        ? '${view.ethiopianMonthLabel} ${view.ethiopianYear}'
        : '${_gregorianMonthLabel(view.gregorianMonth)} ${view.gregorianYear}';
    final monthSubtitle = isEthiopian
        ? '${_gregorianMonthLabel(view.gregorianMonth)} ${view.gregorianYear}'
        : '${view.ethiopianMonthLabel} ${view.ethiopianYear}';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBCBCB), width: 2),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  monthTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ToggleButtons(
                isSelected: [
                  mode == _CalendarViewMode.ethiopian,
                  mode == _CalendarViewMode.gregorian,
                ],
                onPressed: (index) {
                  onModeChanged(
                    index == 0
                        ? _CalendarViewMode.ethiopian
                        : _CalendarViewMode.gregorian,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 28, minWidth: 42),
                children: const [
                  Text('ETH', style: TextStyle(fontSize: 10)),
                  Text('GR', style: TextStyle(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                monthSubtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showYearPicker(
                  context: context,
                  years: years,
                  selectedYear: view.gregorianYear,
                  onPickYear: onPickYear,
                ),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.calendar_view_month, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: onGoToToday,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Today'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: view.weekdayLabels
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          ...view.weeks.map(
            (week) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: week
                    .map(
                      (cell) => Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => onDayTap(cell.dateKey),
                          child: Container(
                            height: view.weeks.length > 5 ? 60 : 68,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: cell.isToday
                                        ? Border.all(
                                            color: Colors.green,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    '${isEthiopian ? cell.ethiopianDay : cell.gregorianDay}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: cell.isCurrentMonth
                                          ? Colors.black87
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${isEthiopian ? cell.gregorianDay : cell.ethiopianDay}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cell.isCurrentMonth
                                        ? Colors.black54
                                        : Colors.black38,
                                  ),
                                ),
                                if (cell.hasDot)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MonthCalendarScroller extends StatefulWidget {
  const _MonthCalendarScroller({
    required this.months,
    required this.years,
    required this.onDayTap,
  });

  final List<CalendarMonthGridView> months;
  final List<int> years;
  final ValueChanged<String> onDayTap;

  @override
  State<_MonthCalendarScroller> createState() => _MonthCalendarScrollerState();
}

class _MonthCalendarScrollerState extends State<_MonthCalendarScroller> {
  late final PageController _pageController;
  late final int _todayIndex;
  _CalendarViewMode _mode = _CalendarViewMode.ethiopian;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final index = widget.months.indexWhere(
      (item) =>
          item.gregorianYear == now.year && item.gregorianMonth == now.month,
    );
    _todayIndex = index >= 0 ? index : (widget.months.length ~/ 2);
    final initialIndex = _todayIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpToYear(int year) {
    final targetIndex = widget.months.indexWhere(
      (item) => item.gregorianYear == year,
    );
    if (targetIndex == -1) {
      return;
    }
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _jumpToToday() {
    _pageController.animateToPage(
      _todayIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.months.length,
        itemBuilder: (context, index) {
          final month = widget.months[index];
          return _CalendarMonthGrid(
            view: month,
            years: widget.years,
            onPickYear: _jumpToYear,
            onGoToToday: _jumpToToday,
            mode: _mode,
            onModeChanged: (mode) => setState(() => _mode = mode),
            onDayTap: widget.onDayTap,
          );
        },
      ),
    );
  }
}

Future<void> _showYearPicker({
  required BuildContext context,
  required List<int> years,
  required int selectedYear,
  required ValueChanged<int> onPickYear,
}) async {
  final selected = await showModalBottomSheet<int>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: years
              .map(
                (year) => ListTile(
                  title: Text('$year'),
                  trailing: year == selectedYear
                      ? const Icon(Icons.check, size: 18)
                      : null,
                  onTap: () => Navigator.of(context).pop(year),
                ),
              )
              .toList(),
        ),
      );
    },
  );
  if (selected != null) {
    onPickYear(selected);
  }
}

String _gregorianMonthLabel(int month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return labels[(month - 1).clamp(0, 11)];
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

class _SaintPreviewCard extends StatelessWidget {
  const _SaintPreviewCard({required this.view, required this.onReadSaint});

  final SaintPreviewView view;
  final VoidCallback onReadSaint;

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
            onPressed: view.isAvailable ? onReadSaint : null,
            child: Text(view.ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _SpiritualTrackerCard extends StatefulWidget {
  const _SpiritualTrackerCard({required this.view});

  final SpiritualTrackerView view;

  @override
  State<_SpiritualTrackerCard> createState() => _SpiritualTrackerCardState();
}

class _SpiritualTrackerCardState extends State<_SpiritualTrackerCard> {
  late final Map<String, bool> _checked = {
    for (final item in widget.view.habits) item.id: item.isDone,
  };
  final List<_TrackerHabitItem> _customHabits = [];

  Future<void> _addHabit() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add tracker item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Type a habit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) {
      return;
    }
    final id = 'custom-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _customHabits.add(
        _TrackerHabitItem(
          id: id,
          label: value,
          isOptional: false,
        ),
      );
      _checked[id] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habits = <_TrackerHabitItem>[
      ...widget.view.habits.map(
        (item) => _TrackerHabitItem(
          id: item.id,
          label: item.label,
          isOptional: item.isOptional,
        ),
      ),
      ..._customHabits,
    ];
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Spiritual Tracker',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _addHabit,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add tracker item',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...habits.map(
            (habit) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checked[habit.id] ?? false,
              dense: true,
              title: Text(
                habit.isOptional ? '${habit.label} (optional)' : habit.label,
                style: const TextStyle(fontSize: 13),
              ),
              onChanged: (value) {
                setState(() {
                  _checked[habit.id] = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerHabitItem {
  const _TrackerHabitItem({
    required this.id,
    required this.label,
    required this.isOptional,
  });

  final String id;
  final String label;
  final bool isOptional;
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

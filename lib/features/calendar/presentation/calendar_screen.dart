import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/calendar_day_detail_adapter.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/calendar_day_detail_providers.dart';
import '../../../core/providers/calendar_preferences_provider.dart';
import '../../../core/providers/screen_state_providers.dart';
import '../../../core/strings/app_strings.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key, this.initialDateKey});

  final String? initialDateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(calendarScreenStateProvider);
    final body = screenState.when(
      data: (state) => _CalendarContent(
        adapter: CalendarAdapter(state),
        initialDateKey: initialDateKey,
      ),
      loading: () => const _CalendarLoading(),
      error: (error, _) => _InlineErrorCard(
        message: 'Unable to load calendar.',
        onRetry: () => ref.refresh(calendarScreenStateProvider),
      ),
    );
    return Scaffold(body: SafeArea(child: body));
  }
}

class _CalendarContent extends ConsumerStatefulWidget {
  const _CalendarContent({required this.adapter, this.initialDateKey});

  final CalendarAdapter adapter;
  final String? initialDateKey;

  @override
  ConsumerState<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<_CalendarContent> {
  late String _selectedDateKey;

  @override
  void initState() {
    super.initState();
    _selectedDateKey = _validDateKey(widget.initialDateKey) ?? _todayYmd();
  }

  @override
  void didUpdateWidget(covariant _CalendarContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextDateKey = _validDateKey(widget.initialDateKey);
    if (nextDateKey != null && nextDateKey != _selectedDateKey) {
      _selectedDateKey = nextDateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(calendarDisplayModeProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TopBar(
          title: widget.adapter.topBarTitle,
          subtitle: widget.adapter.topBarSubtitle,
          icons: widget.adapter.topBarIcons,
        ),
        const SizedBox(height: 14),
        _MonthCalendarScroller(
          months: widget.adapter.monthGrids,
          years: widget.adapter.availableYears,
          mode: mode,
          selectedDateKey: _selectedDateKey,
          onModeChanged: (nextMode) =>
              ref.read(calendarDisplayModeProvider.notifier).setMode(nextMode),
          onDayTap: (dateKey) {
            setState(() => _selectedDateKey = dateKey);
          },
          onMonthChanged: (month) {
            final selected =
                DateTime.tryParse(_selectedDateKey) ?? DateTime.now();
            final lastDay = DateTime(
              month.gregorianYear,
              month.gregorianMonth + 1,
              0,
            ).day;
            final nextDay = selected.day > lastDay ? lastDay : selected.day;
            final nextDateKey = _dateYmd(
              DateTime(month.gregorianYear, month.gregorianMonth, nextDay),
            );
            if (nextDateKey != _selectedDateKey) {
              setState(() => _selectedDateKey = nextDateKey);
            }
          },
        ),
        const SizedBox(height: 18),
        _SelectedDayDetails(dateKey: _selectedDateKey),
      ],
    );
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.view,
    required this.years,
    required this.onPickYear,
    required this.onGoToToday,
    required this.mode,
    required this.selectedDateKey,
    required this.onModeChanged,
    required this.onDayTap,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final CalendarMonthGridView view;
  final List<int> years;
  final ValueChanged<int> onPickYear;
  final VoidCallback onGoToToday;
  final CalendarDisplayMode mode;
  final String selectedDateKey;
  final ValueChanged<CalendarDisplayMode> onModeChanged;
  final ValueChanged<String> onDayTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEthiopian = mode == CalendarDisplayMode.ethiopian;
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  monthTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _MonthArrowButton(
                icon: Icons.chevron_left,
                tooltip: AppStrings.calendarPreviousMonth,
                onPressed: onPreviousMonth,
              ),
              const SizedBox(width: 2),
              _MonthArrowButton(
                icon: Icons.chevron_right,
                tooltip: AppStrings.calendarNextMonth,
                onPressed: onNextMonth,
              ),
              const SizedBox(width: 6),
              ToggleButtons(
                isSelected: [
                  mode == CalendarDisplayMode.ethiopian,
                  mode == CalendarDisplayMode.gregorian,
                ],
                onPressed: (index) {
                  onModeChanged(
                    index == 0
                        ? CalendarDisplayMode.ethiopian
                        : CalendarDisplayMode.gregorian,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 28, minWidth: 38),
                children: const [
                  Text('ETH', style: TextStyle(fontSize: 10)),
                  Text('GR', style: TextStyle(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 6),
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
            (week) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: week
                      .map(
                        (cell) => Expanded(
                          child: Semantics(
                            button: true,
                            selected: cell.dateKey == selectedDateKey,
                            label: cell.dateKey,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => onDayTap(cell.dateKey),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cell.dateKey == selectedDateKey
                                            ? colorScheme.primaryContainer
                                            : null,
                                        border: cell.dateKey == selectedDateKey
                                            ? Border.all(
                                                color: colorScheme.primary,
                                                width: 2,
                                              )
                                            : cell.isToday
                                            ? Border.all(
                                                color: Colors.green,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Text(
                                        '${isEthiopian ? cell.ethiopianDay : cell.gregorianDay}',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          color: cell.isCurrentMonth
                                              ? Colors.black87
                                              : Colors.black38,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '${isEthiopian ? cell.gregorianDay : cell.ethiopianDay}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        height: 1,
                                        color: cell.isCurrentMonth
                                            ? Colors.black54
                                            : Colors.black38,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                      child: cell.hasDot
                                          ? const Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: Colors.green,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 30,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 19),
      ),
    );
  }
}

class _MonthCalendarScroller extends StatefulWidget {
  const _MonthCalendarScroller({
    required this.months,
    required this.years,
    required this.mode,
    required this.selectedDateKey,
    required this.onModeChanged,
    required this.onDayTap,
    required this.onMonthChanged,
  });

  final List<CalendarMonthGridView> months;
  final List<int> years;
  final CalendarDisplayMode mode;
  final String selectedDateKey;
  final ValueChanged<CalendarDisplayMode> onModeChanged;
  final ValueChanged<String> onDayTap;
  final ValueChanged<CalendarMonthGridView> onMonthChanged;

  @override
  State<_MonthCalendarScroller> createState() => _MonthCalendarScrollerState();
}

class _MonthCalendarScrollerState extends State<_MonthCalendarScroller> {
  late final PageController _pageController;
  late final int _todayIndex;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final index = widget.months.indexWhere(
      (item) =>
          item.gregorianYear == now.year && item.gregorianMonth == now.month,
    );
    _todayIndex = index >= 0 ? index : (widget.months.length ~/ 2);
    final selectedDate = DateTime.tryParse(widget.selectedDateKey);
    final selectedIndex = selectedDate == null
        ? -1
        : widget.months.indexWhere(
            (item) =>
                item.gregorianYear == selectedDate.year &&
                item.gregorianMonth == selectedDate.month,
          );
    final initialIndex = selectedIndex >= 0 ? selectedIndex : _todayIndex;
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void didUpdateWidget(covariant _MonthCalendarScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDateKey == widget.selectedDateKey) {
      return;
    }
    final selectedDate = DateTime.tryParse(widget.selectedDateKey);
    if (selectedDate == null) {
      return;
    }
    final targetIndex = widget.months.indexWhere(
      (item) =>
          item.gregorianYear == selectedDate.year &&
          item.gregorianMonth == selectedDate.month,
    );
    if (targetIndex == -1) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _animateToMonth(targetIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpToYear(int year) {
    final visibleMonth = widget.months[_currentIndex].gregorianMonth;
    final targetIndex = widget.months.indexWhere(
      (item) =>
          item.gregorianYear == year && item.gregorianMonth == visibleMonth,
    );
    final fallbackIndex = targetIndex >= 0
        ? targetIndex
        : widget.months.indexWhere((item) => item.gregorianYear == year);
    if (fallbackIndex == -1) {
      return;
    }
    _animateToMonth(fallbackIndex);
  }

  void _animateToMonth(int targetIndex) {
    if (targetIndex < 0 ||
        targetIndex >= widget.months.length ||
        targetIndex == _currentIndex) {
      return;
    }
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _jumpToToday() {
    _animateToMonth(_todayIndex);
    widget.onDayTap(_todayYmd());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          widget.onMonthChanged(widget.months[index]);
        },
        itemCount: widget.months.length,
        itemBuilder: (context, index) {
          final month = widget.months[index];
          return _CalendarMonthGrid(
            view: month,
            years: widget.years,
            onPickYear: _jumpToYear,
            onGoToToday: _jumpToToday,
            mode: widget.mode,
            selectedDateKey: widget.selectedDateKey,
            onModeChanged: widget.onModeChanged,
            onDayTap: widget.onDayTap,
            onPreviousMonth: index > 0
                ? () => _animateToMonth(index - 1)
                : null,
            onNextMonth: index < widget.months.length - 1
                ? () => _animateToMonth(index + 1)
                : null,
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
  return _dateYmd(DateTime.now());
}

String _dateYmd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String? _validDateKey(String? value) {
  if (value == null ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
      DateTime.tryParse(value) == null) {
    return null;
  }
  return value;
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
        ...icons
            .where((icon) => icon == Icons.settings_outlined)
            .map((icon) => _IconButton(icon: icon)),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onTap = icon == Icons.settings_outlined
        ? () => context.push(RoutePaths.settingsPath())
        : null;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: Colors.black54),
        ),
      ),
    );
  }
}

class _SelectedDayDetails extends ConsumerWidget {
  const _SelectedDayDetails({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(calendarDayDetailProvider(dateKey));
    return detailState.when(
      data: (detail) => _SelectedDayContent(
        adapter: CalendarDayDetailAdapter(detail),
        dateKey: dateKey,
      ),
      loading: () => const Column(
        children: [
          _SkeletonBox(height: 94),
          SizedBox(height: 12),
          _SkeletonBox(height: 88),
          SizedBox(height: 12),
          _SkeletonBox(height: 116),
        ],
      ),
      error: (error, _) => _InlineErrorCard(
        message: AppStrings.calendarUnableToLoadSelectedDay,
        onRetry: () => ref.invalidate(calendarDayDetailProvider(dateKey)),
      ),
    );
  }
}

class _SelectedDayContent extends StatelessWidget {
  const _SelectedDayContent({required this.adapter, required this.dateKey});

  final CalendarDayDetailAdapter adapter;
  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateOverviewCard(adapter: adapter),
        const SizedBox(height: 18),
        const _SectionTitle(text: AppStrings.calendarEvangelist),
        const SizedBox(height: 10),
        _InfoCard(
          eyebrow: AppStrings.calendarEvangelist,
          title: adapter.evangelist,
        ),
        const SizedBox(height: 18),
        const _SectionTitle(text: AppStrings.calendarCelebrations),
        const SizedBox(height: 10),
        if (adapter.celebrations.isEmpty)
          const _EmptyCard(text: AppStrings.calendarNoCelebrations)
        else
          ...adapter.celebrations.map(
            (item) => _InfoCard(title: item.title, subtitle: item.subtitle),
          ),
        const SizedBox(height: 18),
        const _SectionTitle(text: AppStrings.calendarSaintsOfDay),
        const SizedBox(height: 10),
        if (adapter.saints.isEmpty)
          const _EmptyCard(text: AppStrings.calendarNoSaints)
        else
          ...adapter.saints.map(
            (item) => _InfoCard(
              title: item.name,
              subtitle: item.snippet,
              actionLabel: AppStrings.calendarReadSynaxarium,
              onTap: () =>
                  context.push(RoutePaths.calendarSynaxariumPath(dateKey)),
            ),
          ),
      ],
    );
  }
}

class _DateOverviewCard extends StatelessWidget {
  const _DateOverviewCard({required this.adapter});

  final CalendarDayDetailAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.calendarSelectedDay,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            adapter.ethiopianDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${adapter.gregorianDate}  |  ${adapter.weekday}',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: colorScheme.primary,
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(title: text);
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

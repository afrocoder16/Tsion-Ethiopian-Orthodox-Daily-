import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const signals = [
      _SignalItem('Evangelist', 'Matthew'),
      _SignalItem('Fast Day', 'Wednesday'),
      _SignalItem('Season', 'Advent'),
      _SignalItem('Cycle', '—'),
      _SignalItem('Day Number', '—'),
    ];

    const upcomingDays = [
      _UpcomingDay('Dec 14', 'St. Ignatius', 'No fasting'),
      _UpcomingDay('Dec 15', 'St. Eleutherius', 'Feast'),
      _UpcomingDay('Dec 16', 'St. Sophia', 'Friday Fast'),
      _UpcomingDay('Dec 17', 'St. Daniel', 'No fasting'),
    ];

    const months = [
      'Today',
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TopBar(),
            const SizedBox(height: 16),
            const _TodayStatusCard(),
            const SizedBox(height: 12),
            _SignalsRow(items: signals),
            const SizedBox(height: 16),
            const _TodayObservanceCard(),
            const SizedBox(height: 12),
            const _TodayActionsRow(),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Upcoming Days'),
            const SizedBox(height: 12),
            _UpcomingList(items: upcomingDays),
            const SizedBox(height: 16),
            _MonthSelector(items: months),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'CALENDAR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Orthodox feasts, fasts, and sacred days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const Spacer(),
        _IconButton(icon: Icons.calendar_today),
        _IconButton(icon: Icons.person),
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
  const _TodayStatusCard();

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
              children: const [
                Text(
                  'Tahsas 4',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'December 13',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wb_sunny_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SignalItem {
  const _SignalItem(this.label, this.value);

  final String label;
  final String value;
}

class _SignalsRow extends StatelessWidget {
  const _SignalsRow({required this.items});

  final List<_SignalItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              '${item.label}: ${item.value}',
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
  const _TodayObservanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Today Observance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          _ObservanceRow(label: 'Saint', value: 'St. Lucia'),
          SizedBox(height: 6),
          _ObservanceRow(label: 'Fast', value: 'Wednesday Fast'),
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
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
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
  const _TodayActionsRow();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _ActionItem('Read Saint', Icons.menu_book),
      _ActionItem('Fasting Rules', Icons.ramen_dining),
      _ActionItem('Open Prayers', Icons.favorite),
    ];
    return Row(
      children: actions
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
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
          )
          .toList(),
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon);

  final String label;
  final IconData icon;
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

class _UpcomingDay {
  const _UpcomingDay(this.date, this.saint, this.label);

  final String date;
  final String saint;
  final String label;
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.items});

  final List<_UpcomingDay> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
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
          )
          .toList(),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = items[index];
          final isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE7E0D6) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}

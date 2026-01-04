import 'package:flutter/material.dart';

class CalendarDayDetailScreen extends StatelessWidget {
  const CalendarDayDetailScreen({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Day $date')),
      body: Center(child: Text('Calendar Day Detail: $date')),
    );
  }
}

import 'package:flutter/material.dart';

class CalendarMonthScreen extends StatelessWidget {
  const CalendarMonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Month')),
      body: Center(child: Text('Calendar Month Screen')),
    );
  }
}

import 'package:flutter/material.dart';

class CalendarTodayScreen extends StatelessWidget {
  const CalendarTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Today')),
      body: Center(child: Text('Calendar Today Screen')),
    );
  }
}

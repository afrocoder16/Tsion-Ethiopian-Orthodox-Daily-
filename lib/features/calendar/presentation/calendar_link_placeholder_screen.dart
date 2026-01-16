import 'package:flutter/material.dart';

class CalendarLinkPlaceholderScreen extends StatelessWidget {
  const CalendarLinkPlaceholderScreen({
    super.key,
    required this.dateKey,
    required this.linkType,
  });

  final String dateKey;
  final String linkType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFromType(linkType))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Placeholder for $linkType on $dateKey.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

String _titleFromType(String linkType) {
  switch (linkType) {
    case 'readings':
      return 'Readings';
    case 'saint':
      return 'Saint';
    case 'prayers':
      return 'Prayers';
  }
  return 'Link';
}

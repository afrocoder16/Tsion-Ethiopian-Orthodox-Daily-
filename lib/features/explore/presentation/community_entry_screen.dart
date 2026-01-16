import 'package:flutter/material.dart';

class CommunityEntryScreen extends StatelessWidget {
  const CommunityEntryScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Placeholder for community entry: $entryId.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

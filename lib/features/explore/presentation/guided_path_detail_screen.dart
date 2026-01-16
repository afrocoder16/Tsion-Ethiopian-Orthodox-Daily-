import 'package:flutter/material.dart';

class GuidedPathDetailScreen extends StatelessWidget {
  const GuidedPathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guided Path')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Placeholder for guided path: $pathId.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

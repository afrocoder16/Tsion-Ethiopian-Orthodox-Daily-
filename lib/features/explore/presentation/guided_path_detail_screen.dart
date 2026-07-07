import 'package:flutter/material.dart';

import 'explore_detail_screen.dart';

/// Guided path bodies live in the Explore content pack, keyed by the
/// title slug the Explore tiles route with.
class GuidedPathDetailScreen extends StatelessWidget {
  const GuidedPathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context) {
    return ExploreDetailScreen(itemId: pathId);
  }
}

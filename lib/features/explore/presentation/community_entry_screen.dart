import 'package:flutter/material.dart';

import 'explore_detail_screen.dart';

/// Community entry bodies live in the Explore content pack, keyed by the
/// title slug the Explore tiles route with.
class CommunityEntryScreen extends StatelessWidget {
  const CommunityEntryScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    return ExploreDetailScreen(itemId: entryId);
  }
}

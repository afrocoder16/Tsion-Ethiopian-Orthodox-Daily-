import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/router_provider.dart';
import '../core/theme/app_theme.dart';

class TsionApp extends ConsumerWidget {
  const TsionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tsion Orthodox Daily',
      routerConfig: router,
      theme: AppTheme.light(),
    );
  }
}

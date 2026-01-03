import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

class TsionApp extends ConsumerWidget {
  const TsionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tsion Orthodox Daily',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}

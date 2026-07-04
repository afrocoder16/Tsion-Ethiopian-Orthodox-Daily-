import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/prayer_notification_service.dart';
import '../core/providers/book_flow_providers.dart';
import '../core/providers/notification_providers.dart';
import '../core/providers/router_provider.dart';
import '../core/providers/sync_providers.dart';
import '../core/theme/app_theme.dart';

class TsionApp extends ConsumerStatefulWidget {
  const TsionApp({
    super.key,
    this.enableNotificationBootstrap = true,
    this.enableBibleBootstrap = true,
  });

  final bool enableNotificationBootstrap;
  final bool enableBibleBootstrap;

  @override
  ConsumerState<TsionApp> createState() => _TsionAppState();
}

class _TsionAppState extends ConsumerState<TsionApp> {
  @override
  void initState() {
    super.initState();
    PrayerNotificationNavigation.pendingRoute.addListener(_openPendingRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingRoute());
  }

  @override
  void dispose() {
    PrayerNotificationNavigation.pendingRoute.removeListener(_openPendingRoute);
    super.dispose();
  }

  void _openPendingRoute() {
    final route = PrayerNotificationNavigation.takePendingRoute();
    if (route == null || !mounted) {
      return;
    }
    ref.read(routerProvider).go(route);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableNotificationBootstrap) {
      ref.watch(prayerNotificationBootstrapProvider);
    }
    if (widget.enableBibleBootstrap) {
      ref.watch(bibleSeedFutureProvider);
    }
    ref.watch(userDataSyncBootstrapProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tsion Orthodox Daily',
      routerConfig: router,
      theme: AppTheme.light(),
    );
  }
}

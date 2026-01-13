import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith(RoutePaths.bible)) return 1;
    if (location.startsWith(RoutePaths.prayers)) return 2;
    if (location.startsWith(RoutePaths.calendar)) return 3;
    if (location.startsWith(RoutePaths.explore)) return 4;
    return 0;
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.today);
        break;
      case 1:
        context.go(RoutePaths.bible);
        break;
      case 2:
        context.go(RoutePaths.prayers);
        break;
      case 3:
        context.go(RoutePaths.calendar);
        break;
      case 4:
        context.go(RoutePaths.explore);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _goToIndex(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Books'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Prayers'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
        ],
      ),
    );
  }
}

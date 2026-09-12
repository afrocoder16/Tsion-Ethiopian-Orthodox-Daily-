import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void popOrGo(BuildContext context, String fallbackPath) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallbackPath);
}

class FallbackBackScope extends StatelessWidget {
  const FallbackBackScope({
    super.key,
    required this.fallbackPath,
    required this.child,
  });

  final String fallbackPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(fallbackPath);
        }
      },
      child: child,
    );
  }
}

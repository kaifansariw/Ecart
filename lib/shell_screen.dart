import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/custom_bottom_nav.dart';

/// Shell screen that wraps the main tabs with the custom bottom nav.
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/search') return 1;
    if (location == '/cart') return 2;
    if (location == '/wishlist') return 3;
    if (location == '/profile') return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/wishlist');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

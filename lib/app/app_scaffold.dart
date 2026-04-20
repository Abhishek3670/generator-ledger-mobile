import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/shared/app_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTabSelected: (index) => _onItemTapped(index, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/gensets')) return 2;
    if (location.startsWith('/vendors')) return 3;
    if (location.startsWith('/more') ||
        location.startsWith('/admin') ||
        location.startsWith('/billing') ||
        location.startsWith('/history')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/bookings');
        break;
      case 2:
        GoRouter.of(context).go('/gensets');
        break;
      case 3:
        GoRouter.of(context).go('/vendors');
        break;
      case 4:
        GoRouter.of(context).go('/more');
        break;
    }
  }
}

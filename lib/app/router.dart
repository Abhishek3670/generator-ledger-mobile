import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_provider.dart';
import '../core/auth/permission_service.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/billing/billing_screen.dart';
import '../features/history/history_screen.dart';
import '../features/bookings/bookings_list_screen.dart';
import '../features/bookings/booking_detail_screen.dart';
import '../features/directory/directory_screen.dart';
import 'app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isInitial) return null;

        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoggingIn) return '/login';
        if (isAuthenticated && isLoggingIn) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            if (authProvider.isInitial) {
              return const AuthBootstrapScreen();
            }
            return AppScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/billing',
              builder: (context, state) => const BillingScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const BookingsListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => BookingDetailScreen(
                    bookingId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/directory',
              builder: (context, state) => const DirectoryScreen(),
            ),
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

class AuthBootstrapScreen extends StatelessWidget {
  const AuthBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bolt, size: 64, color: Color(0xFF0F172A)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();
    final canViewBilling = permissionService.can(PermissionService.billingAccess);
    final canViewHistory = permissionService.can(PermissionService.readOnlyOperationalViews);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          if (canViewBilling)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Billing Lines'),
              subtitle: const Text('View and filter billing records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/billing'),
            ),
          if (canViewHistory)
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              subtitle: const Text('View operational logs'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/history'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }
}

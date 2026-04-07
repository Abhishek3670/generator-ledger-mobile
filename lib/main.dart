import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/auth/auth_service.dart';
import 'core/api/api_client.dart';
import 'core/auth/permission_service.dart';
import 'features/vendors/data/vendor_repository.dart';
import 'features/vendors/providers/vendor_provider.dart';
import 'features/generators/data/generator_repository.dart';
import 'features/generators/providers/generator_provider.dart';
import 'features/bookings/data/booking_repository.dart';
import 'features/bookings/providers/booking_provider.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final authProvider = AuthProvider(authService);
  final apiClient = ApiClient(authProvider);
  authProvider.setApiClient(apiClient);

  final vendorRepository = VendorRepository(apiClient);
  final generatorRepository = GeneratorRepository(apiClient);
  final bookingRepository = BookingRepository(apiClient);
  final dashboardRepository = DashboardRepository(apiClient);
  final permissionService = PermissionService(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider.value(value: apiClient),
        Provider.value(value: permissionService),
        ChangeNotifierProvider(create: (_) => VendorProvider(vendorRepository)),
        ChangeNotifierProvider(create: (_) => GeneratorProvider(generatorRepository)),
        ChangeNotifierProvider(create: (_) => BookingProvider(bookingRepository)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardRepository, permissionService),
        ),
      ],
      child: const GensetLedgerApp(),
    ),
  );
}

class GensetLedgerApp extends StatelessWidget {
  const GensetLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final router = AppRouter.createRouter(authProvider);

    return MaterialApp.router(
      title: 'Genset Ledger',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF1E293B),
          surface: Colors.white,
          background: const Color(0xFFFAFAFA),
          error: const Color(0xFFDC2626),
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }
}

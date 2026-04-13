import 'package:flutter_test/flutter_test.dart';
import 'package:genset_ledger_mobile/main.dart';
import 'package:genset_ledger_mobile/core/auth/auth_service.dart';
import 'package:genset_ledger_mobile/core/auth/auth_provider.dart';
import 'package:genset_ledger_mobile/core/api/api_client.dart';
import 'package:genset_ledger_mobile/app/router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App bootstrap smoke test', (WidgetTester tester) async {
    final authService = AuthService();
    final authProvider = AuthProvider(authService);
    final apiClient = ApiClient(authProvider);
    authProvider.setApiClient(apiClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          Provider.value(value: apiClient),
        ],
        child: const GensetLedgerApp(),
      ),
    );

    // Verify that the bootstrap screen (loading indicator) is shown initially
    expect(find.byType(AuthBootstrapScreen), findsOneWidget);
  });
}

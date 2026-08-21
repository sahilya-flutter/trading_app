import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  testWidgets('TradingApp auth flow & navigation smoke test',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
        child: const TradingApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Unauthenticated user lands on Login Screen
    expect(find.text('021 Trading App'), findsOneWidget);
    expect(find.text('Continue with Google (Gmail)'), findsOneWidget);
    expect(find.text('Quick Demo Trader Login'), findsOneWidget);

    // 2. Perform Quick Demo Login
    final demoButton = find.text('Quick Demo Trader Login');
    await tester.ensureVisible(demoButton);
    await tester.tap(demoButton);
    await tester.pumpAndSettle();

    // 3. User is now logged in and on Market Overview
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.text('10 Universe Stocks'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);

    // 4. Verify Bottom Navigation Tabs
    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);

    // 5. Navigate to Watchlist Tab
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('My Watchlist'), findsOneWidget);

    // 6. Navigate to Holdings Tab
    await tester.tap(find.text('Holdings'));
    await tester.pumpAndSettle();
    expect(find.text('Holdings & Portfolio'), findsOneWidget);
    expect(find.text('Total Current Value'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  testWidgets('TradingApp smoke test - verifies navigation and market screen loads',
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

    // Verify Market Overview is visible
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.text('10 Universe Stocks'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('TCS'), findsOneWidget);

    // Verify Bottom Navigation Items
    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);

    // Tap Watchlist tab
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();

    // Verify Watchlist screen header is displayed
    expect(find.text('My Watchlist'), findsOneWidget);

    // Tap Holdings tab
    await tester.tap(find.text('Holdings'));
    await tester.pumpAndSettle();

    // Verify Holdings & Portfolio screen
    expect(find.text('Holdings & Portfolio'), findsOneWidget);
    expect(find.text('Total Current Value'), findsOneWidget);
  });
}

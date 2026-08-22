import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/order/presentation/order_ticket_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Market Overview Screen UI & Live Price Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('MarketScreen renders 10 universe stocks, header strip, and search filter',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await storage.saveAuthProfile(const UserProfile(
        id: 'test_user',
        email: 'trader@gmail.com',
        displayName: 'Test Trader',
        provider: 'google',
        isDemo: true,
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const TradingApp(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Market tab in navigation bar
      final marketTab = find.text('Market');
      expect(marketTab, findsWidgets);
      await tester.tap(marketTab.first);
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Title & Header strip
      expect(find.text('Market Overview'), findsOneWidget);
      expect(find.text('SYMBOL / COMPANY'), findsOneWidget);
      expect(find.text('LTP / CHG (%)'), findsOneWidget);

      // 2. All 10 stocks present in universe
      for (final stock in StockConstants.initialStocks) {
        expect(find.text(stock.symbol), findsOneWidget);
      }

      // 3. Test Search filtering
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);

      // Search for 'Infosys'
      await tester.enterText(searchInput, 'Infosys');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('INFY'), findsOneWidget);
      expect(find.text('RELIANCE'), findsNothing);
      expect(find.text('TCS'), findsNothing);

      // Clear search
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('TCS'), findsOneWidget);

      // 4. Toggle Stress Mode chip
      final stressChip = find.text('Feed');
      expect(stressChip, findsOneWidget);
      await tester.tap(stressChip);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('50+ t/s'), findsOneWidget);

      // 5. Tap a stock row to open Order Ticket
      await tester.tap(find.byKey(const ValueKey('RELIANCE')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(OrderTicketScreen), findsOneWidget);
      expect(find.text('RELIANCE'), findsWidgets);
    });
  });
}

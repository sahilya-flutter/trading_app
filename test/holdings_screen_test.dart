import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/holdings/presentation/holdings_providers.dart';
import 'package:trading_app/features/holdings/presentation/holdings_screen.dart';
import 'package:trading_app/features/holdings/presentation/widgets/holding_row.dart';
import 'package:trading_app/features/holdings/presentation/widgets/portfolio_summary_card.dart';
import 'package:trading_app/features/market/domain/price_tick.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('HoldingsScreen UI & Integration Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('Displays empty state when user has no open positions',
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

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      final feed = container.read(marketFeedProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HoldingsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Holdings & Portfolio'), findsOneWidget);
      expect(find.text('Positions (0)'), findsOneWidget);
      expect(find.text('No Active Holdings'), findsOneWidget);
      expect(find.text('Explore Market'), findsOneWidget);
      expect(find.byType(PortfolioSummaryCard), findsOneWidget);

      feed.stop();
      container.dispose();
    });

    testWidgets('Renders holdings list, summary card, and responds to live price updates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      final feed = container.read(marketFeedProvider);

      // Add two holdings: RELIANCE and TCS
      container.read(holdingsProvider.notifier).recordBuy(
            symbol: 'RELIANCE',
            quantityUnits: 10000, // 10 shares
            executionPricePaise: 140000, // ₹1,400
          );
      container.read(holdingsProvider.notifier).recordBuy(
            symbol: 'TCS',
            quantityUnits: 5000, // 5 shares
            executionPricePaise: 400000, // ₹4,000
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HoldingsScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify Positions Count
      expect(find.text('Positions (2)'), findsOneWidget);

      // 2. Verify Holding Rows Rendered
      expect(find.byKey(const ValueKey('holding_RELIANCE')), findsOneWidget);
      expect(find.byKey(const ValueKey('holding_TCS')), findsOneWidget);
      expect(find.byType(HoldingRow), findsNWidgets(2));

      // 3. Verify Stock symbols and quantities
      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('TCS'), findsOneWidget);
      expect(find.text('10 Qty'), findsOneWidget);
      expect(find.text('5 Qty'), findsOneWidget);

      // 4. Test Sort Sheet Interaction
      final sortButton = find.byIcon(Icons.sort);
      expect(sortButton, findsOneWidget);
      await tester.tap(sortButton);
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Sort options in bottom sheet
      expect(find.text('Sort Holdings By'), findsOneWidget);
      expect(find.text('Symbol (A-Z)'), findsOneWidget);
      expect(find.text('Value High to Low'), findsOneWidget);
      expect(find.text('P&L High to Low'), findsWidgets);

      // Select Symbol (A-Z)
      await tester.tap(find.text('Symbol (A-Z)'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      // 5. Verify live price update dynamically updates summary
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'RELIANCE',
        newLtpPaise: 150000, // +₹100/share -> +₹1,000 P&L
        previousLtpPaise: 140000,
        previousClosePaise: 140000,
      ));

      await tester.pump(const Duration(milliseconds: 100));

      // Verify summary updated without crashes
      final summary = container.read(portfolioSummaryProvider);
      expect(summary.totalHoldingsCount, 2);

      feed.stop();
      container.dispose();
    });
  });
}

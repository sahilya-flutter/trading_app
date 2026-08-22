import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/home/presentation/home_dashboard_screen.dart';
import 'package:trading_app/features/home/presentation/widgets/market_snapshot_card.dart';
import 'package:trading_app/features/home/presentation/widgets/portfolio_summary_card.dart';
import 'package:trading_app/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:trading_app/features/home/presentation/widgets/recent_orders_list.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Home Dashboard Screen UI & Integration Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('Home Dashboard renders all Stitch UI sections correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pre-save authenticated profile so app opens on Home Dashboard
      await storage.saveAuthProfile(const UserProfile(
        id: 'test_sahil',
        email: 'sahil@gmail.com',
        displayName: 'Sahil',
        provider: 'google',
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const TradingApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header: User Avatar, Title, and Notifications
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
      expect(find.text('021 Trading App'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // 2. Verify Greeting
      expect(find.text('Sahil'), findsOneWidget);

      // 3. Verify Portfolio Summary Card
      expect(find.byType(PortfolioSummaryCard), findsOneWidget);
      expect(find.text('CURRENT VALUE'), findsOneWidget);
      expect(find.text('TOTAL INVESTED'), findsOneWidget);
      expect(find.text('TOTAL P&L'), findsOneWidget);

      // 4. Verify Quick Actions Grid (Buy, Sell, Holdings, Wallet)
      expect(find.byType(QuickActionsGrid), findsOneWidget);
      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('Sell'), findsOneWidget);
      expect(find.text('Holdings'), findsWidgets);
      expect(find.text('Wallet'), findsOneWidget);

      // 5. Verify Market Snapshot Section
      expect(find.byType(MarketSnapshotCard), findsOneWidget);
      expect(find.text('Market Snapshot'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('TCS'), findsOneWidget);
      expect(find.text('INFY'), findsOneWidget);

      // 6. Verify Recent Orders Section
      expect(find.byType(RecentOrdersList), findsOneWidget);
      expect(find.text('Recent Orders'), findsOneWidget);

      // 7. Test Notifications Sheet open
      final notificationBtn = find.byIcon(Icons.notifications_outlined);
      await tester.tap(notificationBtn);
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);

      // Close notification modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 8. Test Wallet modal open
      final walletBtn = find.text('Wallet');
      await tester.tap(walletBtn);
      await tester.pumpAndSettle();
      expect(find.text('Wallet & Funds'), findsOneWidget);
      expect(find.text('ADD DEMO FUNDS'), findsOneWidget);

      // Close wallet modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 9. Test Theme Switcher Button toggle
      final themeBtn = find.byTooltip('Switch to Dark theme');
      expect(themeBtn, findsOneWidget);
      await tester.tap(themeBtn);
      await tester.pumpAndSettle();

      // Now tooltip should update to Light theme
      expect(find.byTooltip('Switch to Light theme'), findsOneWidget);
    });
  });
}

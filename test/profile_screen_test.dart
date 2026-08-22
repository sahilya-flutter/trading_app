import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/order/domain/order_model.dart';
import 'package:trading_app/features/order/domain/order_side.dart';
import 'package:trading_app/features/order/presentation/order_history_screen.dart';
import 'package:trading_app/features/profile/presentation/profile_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Profile Screen UI & Menu Actions Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('Profile Screen renders dynamic data and all menu items are fully functional',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pre-save authenticated profile and sample order
      await storage.saveAuthProfile(const UserProfile(
        id: 'test_user_4821',
        email: 'trader@gmail.com',
        displayName: 'Rahul Sharma',
        phone: '+91 98765 43210',
        provider: 'mobile',
      ));

      await storage.saveOrders([
        OrderModel(
          id: 'ord_1',
          symbol: 'RELIANCE',
          side: OrderSide.buy,
          quantityUnits: 10000,
          executionPricePaise: 142135,
          orderValuePaise: 1421350,
          timestamp: DateTime.now(),
          status: OrderStatus.executed,
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const TradingApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Open Profile from Market AppBar avatar
      final avatarFinder = find.byType(CircleAvatar).first;
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // 1. Verify Header: back arrow and "Profile"
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // 2. Block 1 — Identity Card
      expect(find.text('RS'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Client ID · 021RS4821'), findsOneWidget);

      // 3. Block 2 — Real-time Wallet Strip
      expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
      expect(find.text('INVESTED'), findsOneWidget);

      // 4. Menu Item 1: Test Order History navigation & back
      expect(find.text('Order history'), findsOneWidget);
      expect(find.text('1 orders'), findsOneWidget);
      await tester.tap(find.text('Order history'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderHistoryScreen), findsOneWidget);
      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Navigate back to Profile
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // 4b. Menu Item 1b: Test Holdings navigation
      expect(find.text('Holdings'), findsOneWidget);
      await tester.tap(find.text('Holdings'));
      await tester.pumpAndSettle();
      expect(find.text('Holdings & Portfolio'), findsOneWidget);
      expect(find.text('Total Current Value'), findsOneWidget);

      // Navigate back to Profile via Home tab -> Profile
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      final avatarFinder2 = find.byType(CircleAvatar).first;
      await tester.tap(avatarFinder2);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // 5. Menu Item 2: Test My watchlists sheet open
      expect(find.text('My watchlists'), findsOneWidget);
      await tester.tap(find.text('My watchlists'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Watchlists'), findsOneWidget);
      expect(find.text('My Watchlist'), findsOneWidget);

      // Dismiss watchlists sheet
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // 6. Menu Item 3: Test Tick Rate configuration
      expect(find.text('Tick rate'), findsOneWidget);
      expect(find.text('5 / sec'), findsOneWidget);
      await tester.tap(find.text('Tick rate'));
      await tester.pumpAndSettle();

      expect(find.text('Market Feed Tick Rate'), findsOneWidget);
      expect(find.text('10 / sec'), findsOneWidget);

      // Select 10 / sec
      await tester.tap(find.text('10 / sec'));
      await tester.pumpAndSettle();

      // Verify Profile screen updated to 10 / sec
      expect(find.text('10 / sec'), findsOneWidget);

      // 7. Menu Item 4: Test About modal dialog
      expect(find.text('About'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('021 Trading App'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close About dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // 8. Log Out Action
      final logoutBtn = find.widgetWithText(OutlinedButton, 'Log out');
      expect(logoutBtn, findsOneWidget);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      final confirmLogoutBtn = find.widgetWithText(ElevatedButton, 'Log out');
      await tester.tap(confirmLogoutBtn);
      await tester.pumpAndSettle();

      // Successfully redirected to LoginScreen
      expect(find.text('021 Trade'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}

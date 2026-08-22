import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/order/presentation/order_ticket_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('OrderTicketScreen UI & Real-Time Validation Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('OrderTicketScreen displays live price and validates inputs accurately',
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
          child: const MaterialApp(
            home: OrderTicketScreen(symbol: 'RELIANCE'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify Header & Stock pre-filled
      expect(find.text('RELIANCE Order Ticket'), findsOneWidget);
      expect(find.text('RELIANCE'), findsWidgets);
      expect(find.text('MARKET (LTP)'), findsOneWidget);

      // 2. Default quantity is 1
      final qtyInput = find.byType(TextField);
      expect(qtyInput, findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // 3. Test empty quantity validation
      await tester.enterText(qtyInput, '');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter quantity'), findsOneWidget);

      // 4. Test zero / negative quantity validation
      await tester.enterText(qtyInput, '0');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Quantity must be greater than 0'), findsOneWidget);

      await tester.enterText(qtyInput, '-5');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Quantity must be greater than 0'), findsOneWidget);

      // 5. Test Insufficient Balance on BUY (e.g. 500 shares of RELIANCE ~₹14,90,000 > ₹1,00,000)
      await tester.enterText(qtyInput, '500');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Insufficient balance'), findsOneWidget);

      // 6. Switch to SELL side
      final sellBtn = find.text('SELL');
      expect(sellBtn, findsOneWidget);
      await tester.tap(sellBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // With 0 holdings, SELL 500 should show Insufficient holdings
      expect(find.text('Insufficient holdings (0 shares held)'), findsOneWidget);

      // 7. Switch back to BUY, enter valid quantity 2
      await tester.tap(find.text('BUY'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(qtyInput, '2');
      await tester.pump(const Duration(milliseconds: 100));

      // Error message should be gone
      expect(find.text('Insufficient balance'), findsNothing);
      expect(find.text('Quantity must be greater than 0'), findsNothing);
      expect(find.text('Enter quantity'), findsNothing);

      // 8. Submit button should say BUY RELIANCE
      expect(find.text('BUY RELIANCE'), findsOneWidget);
    });

    testWidgets('Quick quantity chips update input quantity correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: OrderTicketScreen(symbol: 'INFY'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Tap +5 chip (default is 1 -> 1 + 5 = 6)
      await tester.tap(find.text('+5'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('6'), findsOneWidget);

      // Tap +10 chip (6 + 10 = 16)
      await tester.tap(find.text('+10'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('16'), findsOneWidget);
    });
  });
}

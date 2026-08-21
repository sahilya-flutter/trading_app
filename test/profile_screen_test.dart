import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/profile/presentation/profile_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Profile Screen UI Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('Profile Screen renders exact utilitarian specifications',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pre-save authenticated profile so app opens directly
      await storage.saveAuthProfile(const UserProfile(
        id: 'test_user',
        email: 'trader@gmail.com',
        displayName: 'Rahul Sharma',
        phone: '+91 98765 43210',
        provider: 'mobile',
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

      // Open Profile from Market AppBar avatar
      final avatarFinder = find.byType(CircleAvatar).first;
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // 1. Verify Header: back arrow and "Profile" (20 semibold)
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // 2. Block 1 — Identity Card
      expect(find.text('RS'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Client ID · 021RS4821'), findsOneWidget);

      // 3. Block 2 — Wallet Strip
      expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
      expect(find.text('₹9,64,487.50'), findsOneWidget);
      expect(find.text('INVESTED'), findsOneWidget);
      expect(find.text('₹3,64,820.00'), findsOneWidget);

      // 4. Block 3 — Menu List
      expect(find.text('Order history'), findsOneWidget);
      expect(find.text('142 orders'), findsOneWidget);
      expect(find.text('Holdings'), findsOneWidget);
      expect(find.text('My watchlists'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Tick rate'), findsOneWidget);
      expect(find.text('5 / sec'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);

      // 5. Log Out Button and Disclaimer
      final logoutBtn = find.widgetWithText(OutlinedButton, 'Log out');
      expect(logoutBtn, findsOneWidget);
      expect(
        find.text('Simulated trading. No real money involved.'),
        findsOneWidget,
      );

      // 6. Test Confirmation Dialog Variant
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);
      expect(
        find.text('Your watchlists and holdings stay saved on this device.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel dismisses dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsNothing);

      // Tap Log Out again and confirm
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();
      final confirmLogoutBtn = find.widgetWithText(ElevatedButton, 'Log out');
      await tester.tap(confirmLogoutBtn);
      await tester.pumpAndSettle();

      // Successfully redirected to LoginScreen
      expect(find.text('021 Trade'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}

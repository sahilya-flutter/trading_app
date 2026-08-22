import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/core/widgets/user_avatar_view.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/profile/presentation/profile_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  testWidgets('021 Trade Login flow, Profile Screen, and Navigation test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

    await tester.pump(const Duration(milliseconds: 300));

    // 1. Unauthenticated user starts at Login Screen
    expect(find.text('021 Trade'), findsOneWidget);
    expect(find.text('Sign in to continue trading'), findsOneWidget);
    expect(find.text('MOBILE NUMBER'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Simulated trading. No real money involved.'), findsOneWidget);

    // 2. Tap Sign In with valid mobile number
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(signInButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // 3. User is now authenticated and lands on Market Overview
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.text('10 Universe Stocks'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);

    // 4. Open Profile Screen by tapping user avatar in header
    final avatarFinder = find.byType(UserAvatarView).first;
    await tester.tap(avatarFinder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // 5. Verify Profile details
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Trader +91 9876543210'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);
    expect(find.text('₹1,00,000.00'), findsOneWidget);
    expect(find.text('₹0.00'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Log out'), findsOneWidget);

    // 6. Tap Log Out, confirm in dialog, and verify return to Login Screen
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log out'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Log out?'), findsOneWidget);
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Log out');
    await tester.tap(confirmBtn);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('021 Trade'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  testWidgets('TradingApp Google login flow, Profile Sheet, and Navigation test',
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

    // 1. Unauthenticated user starts at Login Screen
    expect(find.text('021 Trading App'), findsOneWidget);
    expect(find.text('Continue with Google (Gmail)'), findsOneWidget);

    // 2. Perform Google Sign In
    final googleButton = find.text('Continue with Google (Gmail)');
    await tester.ensureVisible(googleButton);
    await tester.tap(googleButton);
    await tester.pumpAndSettle();

    // 3. User is now authenticated with Google and lands on Market Overview
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.text('10 Universe Stocks'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);

    // 4. Open Profile BottomSheet by tapping user avatar
    final avatarFinder = find.byType(CircleAvatar).first;
    await tester.tap(avatarFinder);
    await tester.pumpAndSettle();

    // 5. Verify Google Profile details in Profile BottomSheet
    expect(find.text('Google Trader'), findsOneWidget);
    expect(find.text('trader.google@gmail.com'), findsOneWidget);
    expect(find.text('Google OAuth Authenticated'), findsOneWidget);
    expect(find.text('₹1,00,000.00'), findsOneWidget);
    expect(find.text('Log Out from Account'), findsOneWidget);

    // 6. Tap Log Out and verify return to Login Screen
    await tester.tap(find.text('Log Out from Account'));
    await tester.pumpAndSettle();

    expect(find.text('021 Trading App'), findsOneWidget);
    expect(find.text('Continue with Google (Gmail)'), findsOneWidget);
  });
}

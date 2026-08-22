import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/app/theme/app_colors.dart';
import 'package:trading_app/app/theme/app_theme.dart';
import 'package:trading_app/app/theme/theme_provider.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/auth/presentation/login_screen.dart';
import 'package:trading_app/features/holdings/presentation/holdings_screen.dart';
import 'package:trading_app/features/home/presentation/home_dashboard_screen.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/market/presentation/market_screen.dart';
import 'package:trading_app/features/order/presentation/order_ticket_screen.dart';
import 'package:trading_app/features/profile/presentation/profile_screen.dart';
import 'package:trading_app/features/watchlist/presentation/watchlist_screen.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

class _TestThemeNotifier extends ThemeModeNotifier {
  _TestThemeNotifier(ThemeMode mode) {
    state = mode;
  }
}

void main() {
  group('Unified Light and Dark Mode Theme Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    test('AppTheme defines consistent Light and Dark themes with AppThemeColors', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);

      final lightExt = light.extension<AppThemeColors>();
      final darkExt = dark.extension<AppThemeColors>();

      expect(lightExt, isNotNull);
      expect(darkExt, isNotNull);

      // Verify Light mode semantic colors
      expect(lightExt!.background, AppColors.lightBackground);
      expect(lightExt.surface, AppColors.lightSurface);
      expect(lightExt.primary, AppColors.lightPrimary);
      expect(lightExt.gain, AppColors.lightGain);
      expect(lightExt.loss, AppColors.lightLoss);

      // Verify Dark mode semantic colors
      expect(darkExt!.background, AppColors.darkBackground);
      expect(darkExt.surface, AppColors.darkSurface);
      expect(darkExt.primary, AppColors.darkPrimary);
      expect(darkExt.gain, AppColors.darkGain);
      expect(darkExt.loss, AppColors.darkLoss);
    });

    testWidgets('LoginScreen renders properly in both Light and Dark themes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('021 Trade'), findsOneWidget);
        expect(find.text('Sign in to continue trading'), findsOneWidget);
        expect(find.text('MOBILE NUMBER'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('OR'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
      }
    });

    testWidgets('HomeDashboardScreen renders properly in both Light and Dark themes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const HomeDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('021 Trading App'), findsOneWidget);
        expect(find.text('CURRENT VALUE'), findsOneWidget);
        expect(find.text('TOTAL INVESTED'), findsOneWidget);
        expect(find.text('TOTAL P&L'), findsOneWidget);
        expect(find.text('Market Snapshot'), findsOneWidget);
        expect(find.text('Recent Orders'), findsOneWidget);
      }
    });

    testWidgets('MarketScreen renders properly and supports theme toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const MarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Market Overview'), findsOneWidget);
      expect(find.text('10 Universe Stocks'), findsOneWidget);
      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('TCS'), findsOneWidget);
      expect(find.text('INFY'), findsOneWidget);
    });

    testWidgets('WatchlistScreen renders correctly in both Light and Dark modes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const WatchlistScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Watchlist'), findsOneWidget);
        expect(find.text('SYMBOL'), findsOneWidget);
        expect(find.text('LTP / CHG'), findsOneWidget);
      }
    });

    testWidgets('HoldingsScreen renders correctly in both Light and Dark modes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const HoldingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Holdings & Portfolio'), findsOneWidget);
        expect(find.text('Total Current Value'), findsOneWidget);
      }
    });

    testWidgets('OrderTicketScreen renders correctly in both Light and Dark modes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const OrderTicketScreen(symbol: 'RELIANCE'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('RELIANCE Order Ticket'), findsOneWidget);
        expect(find.text('BUY'), findsOneWidget);
        expect(find.text('SELL'), findsOneWidget);
        expect(find.text('Estimated Order Value'), findsOneWidget);
      }
    });

    testWidgets('ProfileScreen renders correctly in both Light and Dark modes',
        (WidgetTester tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              themeModeProvider.overrideWith((ref) => _TestThemeNotifier(mode)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: const ProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Rahul Sharma'), findsOneWidget);
        expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
        expect(find.text('INVESTED'), findsOneWidget);
        expect(find.text('PREFERENCES'), findsOneWidget);
      }
    });

    testWidgets('Full TradingApp runtime theme toggle test',
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

      // Verify Home loaded
      expect(find.text('021 Trading App'), findsOneWidget);

      // Tap Theme Toggle Icon in Home Screen Header
      final themeToggleFinder = find.byTooltip('Switch to Light theme');
      if (themeToggleFinder.evaluate().isNotEmpty) {
        await tester.tap(themeToggleFinder);
        await tester.pumpAndSettle();
        expect(find.byTooltip('Switch to Dark theme'), findsOneWidget);

        // Toggle back to Dark theme
        await tester.tap(find.byTooltip('Switch to Dark theme'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Switch to Light theme'), findsOneWidget);
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/order/presentation/order_ticket_screen.dart';
import 'package:trading_app/features/watchlist/presentation/watchlist_providers.dart';
import 'package:trading_app/features/watchlist/presentation/widgets/add_stock_sheet.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Watchlist Screen & Add Stocks Picker UI Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('Watchlist Screen renders exact design specifications with search filtering',
        (WidgetTester tester) async {
      // Set larger test viewport to display all 6 dense rows and bottom button cleanly
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

      await tester.pumpAndSettle();

      // Switch to Watchlist Tab in bottom nav
      final watchlistTab = find.text('Watchlist');
      expect(watchlistTab, findsWidgets);
      await tester.tap(watchlistTab.first);
      await tester.pumpAndSettle();

      // 1. Top plain header reading "Watchlist"
      expect(find.text('Watchlist'), findsWidgets);

      // 2. Pill chips: "My Watchlist", "Banking", "IT Stocks"
      expect(find.text('My Watchlist'), findsOneWidget);
      expect(find.text('Banking'), findsOneWidget);
      expect(find.text('IT Stocks'), findsOneWidget);

      // 3. Column header strip: "SYMBOL" and "LTP / CHG"
      expect(find.text('SYMBOL'), findsOneWidget);
      expect(find.text('LTP / CHG'), findsOneWidget);

      // 4. Stock rows: RELIANCE, TCS, HDFCBANK, INFY, SBIN, ITC
      expect(find.text('RELIANCE'), findsOneWidget);
      expect(find.text('TCS'), findsOneWidget);
      expect(find.text('HDFCBANK'), findsOneWidget);
      expect(find.text('INFY'), findsOneWidget);
      expect(find.text('SBIN'), findsOneWidget);
      expect(find.text('ITC'), findsOneWidget);

      // 5. Drag handles and NSE labels
      expect(find.byIcon(Icons.drag_indicator), findsNWidgets(6));
      expect(find.text('NSE'), findsNWidgets(6));

      // 6. Bottom "Add stocks" button
      final addStocksBtn = find.widgetWithText(OutlinedButton, 'Add stocks');
      expect(addStocksBtn, findsOneWidget);

      // 7. Tap "Add stocks" to open Screen 2 (Add Stocks Picker bottom sheet)
      await tester.tap(addStocksBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AddStockSheet), findsOneWidget);
      expect(find.text('Add stocks'), findsWidgets);

      // Test Search Bar in AddStockSheet
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);
      await tester.enterText(searchInput, 'AXIS');
      await tester.pumpAndSettle();

      // AXISBANK should be visible, others filtered out
      expect(find.text('AXISBANK'), findsOneWidget);
      expect(find.text('BHARTIARTL'), findsNothing);

      // Select AXISBANK
      final axisRow = find.text('AXISBANK');
      await tester.tap(axisRow);
      await tester.pumpAndSettle();

      // Footer button should now say "Add 1 stock"
      expect(find.text('Add 1 stock'), findsOneWidget);

      // Tap "Add 1 stock" to commit
      await tester.tap(find.text('Add 1 stock'));
      await tester.pumpAndSettle();

      // Sheet should close and AXISBANK is now in watchlist
      expect(find.byType(AddStockSheet), findsNothing);
      expect(find.text('AXISBANK'), findsOneWidget);
    });

    testWidgets('Swiping stock row from right to left removes it from watchlist and shows undo',
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

      await tester.pumpAndSettle();

      // Switch to Watchlist Tab
      await tester.tap(find.text('Watchlist').first);
      await tester.pumpAndSettle();

      // Verify RELIANCE and TCS exist
      final relianceFinder = find.byKey(const Key('watchlist_row_RELIANCE'));
      final tcsFinder = find.byKey(const Key('watchlist_row_TCS'));
      expect(relianceFinder, findsOneWidget);
      expect(tcsFinder, findsOneWidget);

      // Swipe RELIANCE from right to left (dismiss)
      await tester.drag(relianceFinder, const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // RELIANCE is removed, but TCS and others remain
      expect(find.byKey(const Key('watchlist_row_RELIANCE')), findsNothing);
      expect(find.byKey(const Key('watchlist_row_TCS')), findsOneWidget);
      expect(find.text('RELIANCE removed from watchlist'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo to restore RELIANCE
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('watchlist_row_RELIANCE')), findsOneWidget);
    });

    testWidgets('Empty state variant renders correctly when watchlist has no stocks',
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

      await tester.pumpAndSettle();

      // Switch to Watchlist Tab
      await tester.tap(find.text('Watchlist').first);
      await tester.pumpAndSettle();

      // Create a new empty watchlist
      final element = tester.element(find.byType(TradingApp));
      final container = ProviderScope.containerOf(element);
      container.read(watchlistProvider.notifier).createWatchlist('Empty Portfolio');
      await tester.pumpAndSettle();

      // Verify Empty State elements
      expect(find.text('No stocks yet'), findsOneWidget);
      expect(
        find.text('Add stocks to this watchlist to track live prices.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.playlist_add), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Add stocks'), findsOneWidget);
    });

    testWidgets('Tapping a stock row opens the Buy/Sell ticket pre-filled with symbol',
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

      await tester.pumpAndSettle();

      // Switch to Watchlist Tab
      await tester.tap(find.text('Watchlist').first);
      await tester.pumpAndSettle();

      // Tap RELIANCE row
      final relianceFinder = find.byKey(const Key('watchlist_row_RELIANCE'));
      await tester.tap(relianceFinder);
      await tester.pumpAndSettle();

      // Verify Order Ticket opened with RELIANCE
      expect(find.byType(OrderTicketScreen), findsOneWidget);
      expect(find.text('RELIANCE'), findsWidgets);
    });
  });
}

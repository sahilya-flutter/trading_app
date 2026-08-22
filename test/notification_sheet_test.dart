import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/app/app.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/features/home/presentation/home_dashboard_screen.dart';
import 'package:trading_app/features/home/presentation/widgets/notification_sheet.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/notifications/domain/notification_item.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Notification Sheet & Home Header Badge UI Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
    });

    testWidgets('NotificationSheet displays real notifications, read states, and Mark All As Read',
        (WidgetTester tester) async {
      // Pre-save 2 notifications: 1 unread, 1 read
      await storage.saveNotifications([
        NotificationItem(
          id: 'notif_1',
          title: 'BUY order completed',
          message: 'Bought 10 RELIANCE at ₹1,421.35',
          type: NotificationType.orderBuy,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        NotificationItem(
          id: 'notif_2',
          title: 'Watchlist updated',
          message: 'TCS added to My Watchlist',
          type: NotificationType.watchlist,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Header and Unread Badge Count
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // 1 unread
      expect(find.text('Mark all as read'), findsOneWidget);

      // 2. Verify List Items
      expect(find.text('BUY order completed'), findsOneWidget);
      expect(find.text('Bought 10 RELIANCE at ₹1,421.35'), findsOneWidget);
      expect(find.text('Watchlist updated'), findsOneWidget);
      expect(find.text('TCS added to My Watchlist'), findsOneWidget);

      // 3. Tap Mark All As Read
      await tester.tap(find.text('Mark all as read'));
      await tester.pumpAndSettle();

      // Unread count badge disappears and 'Mark all as read' disappears
      expect(find.text('Mark all as read'), findsNothing);
    });

    testWidgets('NotificationSheet renders empty state cleanly when no notifications exist',
        (WidgetTester tester) async {
      await storage.saveNotifications([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text('Real-time updates about your orders, holdings, and watchlists will appear here.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
    });

    testWidgets('Home Dashboard shows live unread count on Notification Bell and opens sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await storage.saveAuthProfile(const UserProfile(
        id: 'user_1',
        email: 'user@test.com',
        displayName: 'Sahil',
        provider: 'google',
      ));

      await storage.saveNotifications([
        NotificationItem(
          id: 'notif_1',
          title: 'Holdings updated',
          message: 'INFY added to Holdings',
          type: NotificationType.holding,
          timestamp: DateTime.now(),
          isRead: false,
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

      expect(find.byType(HomeDashboardScreen), findsOneWidget);

      // Verify unread badge '1' on Bell
      expect(find.text('1'), findsOneWidget);

      // Tap Notification Bell
      final bellFinder = find.byIcon(Icons.notifications_outlined);
      expect(bellFinder, findsOneWidget);
      await tester.tap(bellFinder);
      await tester.pumpAndSettle();

      // Sheet opens
      expect(find.byType(NotificationSheet), findsOneWidget);
      expect(find.text('INFY added to Holdings'), findsOneWidget);
    });
  });
}

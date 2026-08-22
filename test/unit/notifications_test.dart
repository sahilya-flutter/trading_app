import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/notifications/domain/notification_item.dart';
import 'package:trading_app/features/notifications/presentation/notifications_providers.dart';
import 'package:trading_app/features/order/domain/order_side.dart';
import 'package:trading_app/features/order/presentation/order_providers.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/wallet/presentation/wallet_providers.dart';
import 'package:trading_app/features/watchlist/presentation/watchlist_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Notifications Unit & Real Event Integration Tests', () {
    late LocalStorageService storage;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
      container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('NotificationsNotifier adds, marks as read, removes, and persists notifications', () {
      final notifier = container.read(notificationsProvider.notifier);

      expect(container.read(notificationsProvider), isEmpty);
      expect(container.read(unreadNotificationsCountProvider), 0);

      // Add a notification
      final item = notifier.addNotification(
        title: 'Watchlist updated',
        message: 'RELIANCE added to My Watchlist',
        type: NotificationType.watchlist,
        metadata: {'symbol': 'RELIANCE'},
      );

      final list = container.read(notificationsProvider);
      expect(list.length, 1);
      expect(list.first.title, 'Watchlist updated');
      expect(list.first.message, 'RELIANCE added to My Watchlist');
      expect(list.first.isRead, false);
      expect(container.read(unreadNotificationsCountProvider), 1);

      // Mark single as read
      notifier.markAsRead(item.id);
      expect(container.read(notificationsProvider).first.isRead, true);
      expect(container.read(unreadNotificationsCountProvider), 0);

      // Add another notification
      notifier.addNotification(
        title: 'BUY order completed',
        message: 'Bought 10 TCS at ₹3,850.00',
        type: NotificationType.orderBuy,
      );

      expect(container.read(notificationsProvider).length, 2);
      expect(container.read(unreadNotificationsCountProvider), 1);

      // Mark all as read
      notifier.markAllAsRead();
      expect(container.read(unreadNotificationsCountProvider), 0);

      // Remove single
      notifier.removeNotification(item.id);
      expect(container.read(notificationsProvider).length, 1);

      // Clear all
      notifier.clearAll();
      expect(container.read(notificationsProvider), isEmpty);
    });

    test('Watchlist real events dispatch appropriate notifications', () {
      final watchlistNotifier = container.read(watchlistProvider.notifier);

      // 1. Add Stock
      watchlistNotifier.addStockToActiveWatchlist('BHARTIARTL');
      final notificationsAfterAdd = container.read(notificationsProvider);
      expect(notificationsAfterAdd.length, 1);
      expect(notificationsAfterAdd.first.title, 'Watchlist updated');
      expect(notificationsAfterAdd.first.message, contains('BHARTIARTL added to'));

      // 2. Remove Stock
      watchlistNotifier.removeStockFromActiveWatchlist('BHARTIARTL');
      final notificationsAfterRemove = container.read(notificationsProvider);
      expect(notificationsAfterRemove.length, 2);
      expect(notificationsAfterRemove.first.message, contains('BHARTIARTL removed from'));

      // 3. Create Watchlist
      final newId = watchlistNotifier.createWatchlist('Crypto & Tech');
      final notificationsAfterCreate = container.read(notificationsProvider);
      expect(notificationsAfterCreate.first.title, 'Watchlist created');
      expect(notificationsAfterCreate.first.message, 'Crypto & Tech watchlist created');

      // 4. Rename Watchlist
      watchlistNotifier.renameWatchlist(newId, 'Global Tech');
      final notificationsAfterRename = container.read(notificationsProvider);
      expect(notificationsAfterRename.first.title, 'Watchlist renamed');
      expect(notificationsAfterRename.first.message, 'Crypto & Tech renamed to Global Tech');

      // 5. Delete Watchlist
      watchlistNotifier.deleteWatchlist(newId);
      final notificationsAfterDelete = container.read(notificationsProvider);
      expect(notificationsAfterDelete.first.title, 'Watchlist deleted');
      expect(notificationsAfterDelete.first.message, 'Global Tech watchlist deleted');
    });

    test('Buy and Sell real order execution dispatches Order and Holdings notifications', () {
      final orderNotifier = container.read(orderHistoryProvider.notifier);

      // Set initial wallet funds
      container.read(walletProvider.notifier).credit(5000000); // ₹50,000

      // Execute Buy Order for 10 RELIANCE (10000 minor units)
      final buyResult = orderNotifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantityUnits: 10000,
      );

      expect(buyResult.isSuccess, true);

      final notificationsAfterBuy = container.read(notificationsProvider);
      // Expected 2 notifications: 1 for Holdings updated, 1 for BUY order completed
      expect(notificationsAfterBuy.length, 2);

      final orderNotification = notificationsAfterBuy.firstWhere(
        (n) => n.type == NotificationType.orderBuy,
      );
      expect(orderNotification.title, 'BUY order completed');
      expect(orderNotification.message, contains('Bought 10 RELIANCE at'));

      final holdingNotification = notificationsAfterBuy.firstWhere(
        (n) => n.type == NotificationType.holding,
      );
      expect(holdingNotification.title, 'Holdings updated');
      expect(holdingNotification.message, 'RELIANCE added to Holdings');

      // Execute Partial Sell Order for 5 RELIANCE (5000 minor units)
      final sellResult = orderNotifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.sell,
        quantityUnits: 5000,
      );

      expect(sellResult.isSuccess, true);

      final notificationsAfterSell = container.read(notificationsProvider);
      expect(notificationsAfterSell.length, 4);

      final sellOrderNotification = notificationsAfterSell.firstWhere(
        (n) => n.type == NotificationType.orderSell,
      );
      expect(sellOrderNotification.title, 'SELL order completed');
      expect(sellOrderNotification.message, contains('Sold 5 RELIANCE at'));

      // Execute Full Sell of remaining 5 units
      orderNotifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.sell,
        quantityUnits: 5000,
      );

      final notificationsAfterFullSell = container.read(notificationsProvider);
      final closedHoldingNotification = notificationsAfterFullSell.firstWhere(
        (n) => n.type == NotificationType.holding && n.message.contains('removed from Holdings'),
      );
      expect(closedHoldingNotification.message, 'RELIANCE removed from Holdings');
    });

    test('Notifications restore from LocalStorageService on container re-initialization', () async {
      final notifier = container.read(notificationsProvider.notifier);
      notifier.addNotification(
        title: 'System Alert',
        message: 'Market opened successfully',
        type: NotificationType.system,
      );

      // Create new container simulating app restart
      final newContainer = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(newContainer.dispose);

      final restored = newContainer.read(notificationsProvider);
      expect(restored.length, 1);
      expect(restored.first.title, 'System Alert');
      expect(restored.first.message, 'Market opened successfully');
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/app_constants.dart';
import 'package:trading_app/features/holdings/presentation/holdings_providers.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/order/domain/order_side.dart';
import 'package:trading_app/features/order/presentation/order_providers.dart';
import 'package:trading_app/features/wallet/presentation/wallet_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Order Execution & Wallet/Holding Integration Tests', () {
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

    test('Initial wallet balance starts at ₹1,00,000.00 (10,000,000 paise)', () {
      final balance = container.read(walletBalancePaiseProvider);
      expect(balance, AppConstants.initialWalletBalancePaise);
    });

    test('Zero or negative quantity is strictly rejected without state changes', () {
      final notifier = container.read(orderHistoryProvider.notifier);
      final initialBalance = container.read(walletBalancePaiseProvider);

      final zeroResult = notifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantityUnits: 0,
      );
      expect(zeroResult.isSuccess, isFalse);
      expect(zeroResult.errorMessage, contains('greater than zero'));

      final negResult = notifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantityUnits: -1000,
      );
      expect(negResult.isSuccess, isFalse);
      expect(container.read(walletBalancePaiseProvider), initialBalance);
      expect(container.read(holdingsProvider).isEmpty, isTrue);
    });

    test('Buy order succeeds, deducts wallet, and creates holding', () {
      final notifier = container.read(orderHistoryProvider.notifier);
      final initialBalance = container.read(walletBalancePaiseProvider);

      // Buy 2 shares (2000 units) of RELIANCE
      final result = notifier.executeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantityUnits: 2000,
      );

      expect(result.isSuccess, isTrue);
      expect(result.order, isNotNull);
      expect(result.order!.symbol, 'RELIANCE');
      expect(result.order!.side, OrderSide.buy);

      // Wallet should decrease by order value
      final orderVal = result.order!.orderValuePaise;
      final newBalance = container.read(walletBalancePaiseProvider);
      expect(newBalance, initialBalance - orderVal);

      // Holdings should contain RELIANCE with 2000 units
      final holdings = container.read(holdingsProvider);
      expect(holdings.containsKey('RELIANCE'), isTrue);
      expect(holdings['RELIANCE']!.quantityUnits, 2000);
      expect(holdings['RELIANCE']!.averagePricePaise, result.order!.executionPricePaise);

      // Order history should contain this order
      final orders = container.read(orderHistoryProvider);
      expect(orders.first.id, result.order!.id);
    });

    test('Buying additional shares recalculates weighted average price accurately', () {
      final notifier = container.read(orderHistoryProvider.notifier);

      // Buy 1 share of TCS
      final buy1 = notifier.executeOrder(
        symbol: 'TCS',
        side: OrderSide.buy,
        quantityUnits: 1000,
      );
      expect(buy1.isSuccess, isTrue);

      final price1 = buy1.order!.executionPricePaise;

      // Buy 2 more shares of TCS
      final buy2 = notifier.executeOrder(
        symbol: 'TCS',
        side: OrderSide.buy,
        quantityUnits: 2000,
      );
      expect(buy2.isSuccess, isTrue);

      final price2 = buy2.order!.executionPricePaise;
      final expectedAvg = ((1000 * price1) + (2000 * price2)) ~/ 3000;

      final holdings = container.read(holdingsProvider);
      expect(holdings['TCS']!.quantityUnits, 3000);
      expect(holdings['TCS']!.averagePricePaise, expectedAvg);
    });

    test('Buy order fails when order value exceeds wallet balance', () {
      final notifier = container.read(orderHistoryProvider.notifier);

      // Try buying 1000 shares of TCS (worth ~₹39,00,000, way over ₹1,00,000 balance)
      final result = notifier.executeOrder(
        symbol: 'TCS',
        side: OrderSide.buy,
        quantityUnits: 1000 * 1000,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Insufficient cash balance'));
      expect(container.read(holdingsProvider).containsKey('TCS'), isFalse);
    });

    test('Sell order reduces holding and credits wallet; full sell removes holding', () {
      final notifier = container.read(orderHistoryProvider.notifier);

      // 1. Buy 5 shares of INFY
      notifier.executeOrder(
        symbol: 'INFY',
        side: OrderSide.buy,
        quantityUnits: 5000,
      );

      final balanceAfterBuy = container.read(walletBalancePaiseProvider);

      // 2. Partial Sell 2 shares
      final partialSellResult = notifier.executeOrder(
        symbol: 'INFY',
        side: OrderSide.sell,
        quantityUnits: 2000,
      );

      expect(partialSellResult.isSuccess, isTrue);
      final holdingsAfterPartial = container.read(holdingsProvider);
      expect(holdingsAfterPartial['INFY']!.quantityUnits, 3000);
      expect(
        container.read(walletBalancePaiseProvider),
        balanceAfterBuy + partialSellResult.order!.orderValuePaise,
      );

      // 3. Full Sell remaining 3 shares
      final fullSellResult = notifier.executeOrder(
        symbol: 'INFY',
        side: OrderSide.sell,
        quantityUnits: 3000,
      );

      expect(fullSellResult.isSuccess, isTrue);
      final holdingsAfterFull = container.read(holdingsProvider);
      expect(holdingsAfterFull.containsKey('INFY'), isFalse); // Removed on 0 qty!
    });

    test('Sell order fails if quantity > held quantity', () {
      final notifier = container.read(orderHistoryProvider.notifier);

      // Attempt to sell without holding any shares
      final result = notifier.executeOrder(
        symbol: 'HDFCBANK',
        side: OrderSide.sell,
        quantityUnits: 1000,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Cannot sell more than held quantity'));
    });

    test('State persists correctly in LocalStorageService after Buy and Sell operations', () async {
      final notifier = container.read(orderHistoryProvider.notifier);

      notifier.executeOrder(
        symbol: 'SBIN',
        side: OrderSide.buy,
        quantityUnits: 4000,
      );

      final currentBalance = container.read(walletBalancePaiseProvider);

      // Re-create storage and container to simulate cold app restart
      final freshStorage = await LocalStorageService.create();
      final freshContainer = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(freshStorage),
        ],
      );

      expect(freshContainer.read(walletBalancePaiseProvider), currentBalance);
      final freshHoldings = freshContainer.read(holdingsProvider);
      expect(freshHoldings.containsKey('SBIN'), isTrue);
      expect(freshHoldings['SBIN']!.quantityUnits, 4000);

      final freshOrders = freshContainer.read(orderHistoryProvider);
      expect(freshOrders.length, 1);
      expect(freshOrders.first.symbol, 'SBIN');

      freshContainer.dispose();
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../persistence/local_storage_service.dart';
import '../../holdings/presentation/holdings_providers.dart';
import '../../market/presentation/market_providers.dart';
import '../../notifications/domain/notification_item.dart';
import '../../notifications/presentation/notifications_providers.dart';
import '../../wallet/presentation/wallet_providers.dart';
import '../domain/order_model.dart';
import '../domain/order_side.dart';

class OrderExecutionResult {
  final bool isSuccess;
  final String? errorMessage;
  final OrderModel? order;

  const OrderExecutionResult.success(this.order)
      : isSuccess = true,
        errorMessage = null;

  const OrderExecutionResult.failure(this.errorMessage)
      : isSuccess = false,
        order = null;
}

class OrderHistoryNotifier extends StateNotifier<List<OrderModel>> {
  final LocalStorageService _storage;
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  OrderHistoryNotifier(this._storage, this._ref)
      : super(_storage.loadOrders());

  void _persist() {
    _storage.saveOrders(state);
  }

  /// Executes an order atomically using the exact live price at the moment of submission
  OrderExecutionResult executeOrder({
    required String symbol,
    required OrderSide side,
    required int quantityUnits,
  }) {
    if (quantityUnits <= 0) {
      return const OrderExecutionResult.failure('Quantity must be greater than zero');
    }

    // 1. Re-read the exact authoritative current price at the submit moment
    final feed = _ref.read(marketFeedProvider);
    final executionPricePaise = feed.getLtpPaise(symbol);
    if (executionPricePaise <= 0) {
      return const OrderExecutionResult.failure('Invalid stock price from market feed');
    }

    // 2. Compute exact order value in integer paise
    final orderValuePaise = QuantityUtils.calculateOrderValuePaise(
      quantityUnits,
      executionPricePaise,
    );

    final qtyFormatted = QuantityUtils.formatQuantity(
      quantityUnits,
      trimTrailingZeros: true,
    );
    final priceFormatted = MoneyFormatter.formatPaise(executionPricePaise);

    if (side == OrderSide.buy) {
      // Validate Wallet Balance
      final currentBalance = _ref.read(walletBalancePaiseProvider);
      if (orderValuePaise > currentBalance) {
        return const OrderExecutionResult.failure(
          'Insufficient cash balance to place this buy order',
        );
      }

      // Deduct Wallet
      final deducted = _ref.read(walletProvider.notifier).deduct(orderValuePaise);
      if (!deducted) {
        return const OrderExecutionResult.failure('Failed to deduct wallet balance');
      }

      final previousHolding = _ref.read(holdingsProvider)[symbol];
      final isNewHolding = previousHolding == null || previousHolding.quantityUnits <= 0;

      // Update Holdings
      _ref.read(holdingsProvider.notifier).recordBuy(
            symbol: symbol,
            quantityUnits: quantityUnits,
            executionPricePaise: executionPricePaise,
          );

      // Order Notification
      _ref.read(notificationsProvider.notifier).addNotification(
            title: 'BUY order completed',
            message: 'Bought $qtyFormatted $symbol at $priceFormatted',
            type: NotificationType.orderBuy,
            metadata: {
              'symbol': symbol,
              'side': 'buy',
              'quantityUnits': quantityUnits,
              'pricePaise': executionPricePaise,
            },
          );

      // Holdings Notification
      _ref.read(notificationsProvider.notifier).addNotification(
            title: 'Holdings updated',
            message: isNewHolding
                ? '$symbol added to Holdings'
                : '$symbol holding updated',
            type: NotificationType.holding,
            metadata: {'symbol': symbol},
          );
    } else {
      // Validate Sell Holding
      final holdingsMap = _ref.read(holdingsProvider);
      final currentHolding = holdingsMap[symbol];
      final heldUnits = currentHolding?.quantityUnits ?? 0;

      if (quantityUnits > heldUnits) {
        return OrderExecutionResult.failure(
          'Cannot sell more than held quantity (${QuantityUtils.formatQuantity(heldUnits)} units available)',
        );
      }

      final isHoldingClosed = heldUnits == quantityUnits;

      // Update Holdings
      final sold = _ref.read(holdingsProvider.notifier).recordSell(
            symbol: symbol,
            quantityUnits: quantityUnits,
          );

      if (!sold) {
        return const OrderExecutionResult.failure('Failed to update holdings');
      }

      // Credit Wallet
      _ref.read(walletProvider.notifier).credit(orderValuePaise);

      // Order Notification
      _ref.read(notificationsProvider.notifier).addNotification(
            title: 'SELL order completed',
            message: 'Sold $qtyFormatted $symbol at $priceFormatted',
            type: NotificationType.orderSell,
            metadata: {
              'symbol': symbol,
              'side': 'sell',
              'quantityUnits': quantityUnits,
              'pricePaise': executionPricePaise,
            },
          );

      // Holdings Notification
      _ref.read(notificationsProvider.notifier).addNotification(
            title: 'Holdings updated',
            message: isHoldingClosed
                ? '$symbol removed from Holdings'
                : '$symbol holding updated',
            type: NotificationType.holding,
            metadata: {'symbol': symbol},
          );
    }

    // 3. Record order in history
    final executedOrder = OrderModel(
      id: _uuid.v4(),
      symbol: symbol,
      side: side,
      quantityUnits: quantityUnits,
      executionPricePaise: executionPricePaise,
      orderValuePaise: orderValuePaise,
      timestamp: DateTime.now(),
      status: OrderStatus.executed,
    );

    state = [executedOrder, ...state];
    _persist();

    return OrderExecutionResult.success(executedOrder);
  }
}

final orderHistoryProvider =
    StateNotifierProvider<OrderHistoryNotifier, List<OrderModel>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return OrderHistoryNotifier(storage, ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../persistence/local_storage_service.dart';
import '../data/mock_market_feed.dart';
import '../domain/price_tick.dart';
import '../domain/stock.dart';

/// Local Storage Service Provider (Overridden in main with initialized instance)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden');
});

/// Central Mock Market Feed Singleton Provider
final marketFeedProvider = Provider<MockMarketFeed>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final initialRate = storage.loadTickRate();
  final feed = MockMarketFeed(initialTickRate: initialRate);
  feed.start();
  ref.onDispose(() {
    feed.dispose();
  });
  return feed;
});

/// Tick rate notifier that persists and controls feed interval
class TickRateNotifier extends StateNotifier<int> {
  final MockMarketFeed _feed;
  final LocalStorageService _storage;

  TickRateNotifier(this._feed, this._storage)
      : super(_storage.loadTickRate()) {
    _feed.setTickRate(state);
  }

  void setTickRate(int rate) {
    if (rate <= 0) return;
    state = rate;
    _feed.setTickRate(rate);
    _storage.saveTickRate(rate);
  }
}

final tickRateProvider =
    StateNotifierProvider<TickRateNotifier, int>((ref) {
  final feed = ref.watch(marketFeedProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return TickRateNotifier(feed, storage);
});

/// Stress mode toggle provider
final stressModeProvider =
    StateNotifierProvider<StressModeNotifier, bool>((ref) {
  final feed = ref.watch(marketFeedProvider);
  return StressModeNotifier(feed);
});

class StressModeNotifier extends StateNotifier<bool> {
  final MockMarketFeed _feed;
  StressModeNotifier(this._feed) : super(_feed.isStressMode);

  void toggle() {
    state = !state;
    _feed.setStressMode(state);
  }

  void setStressMode(bool enable) {
    state = enable;
    _feed.setStressMode(enable);
  }
}

/// Fixed stock list provider
final allStocksProvider = Provider<List<Stock>>((ref) {
  return StockConstants.initialStocks;
});

/// Central market ticks notifier that holds the map of latest ticks
class MarketPricesNotifier extends StateNotifier<Map<String, PriceTick>> {
  final MockMarketFeed _feed;

  MarketPricesNotifier(this._feed) : super(_feed.allCurrentTicks) {
    _feed.tickStream.listen((tick) {
      // Update the map immutably
      state = {
        ...state,
        tick.symbol: tick,
      };
    });
  }
}

final marketPricesProvider =
    StateNotifierProvider<MarketPricesNotifier, Map<String, PriceTick>>((ref) {
  final feed = ref.watch(marketFeedProvider);
  return MarketPricesNotifier(feed);
});

/// Highly optimized granular provider for a single symbol
/// Only widgets watching this exact symbol will rebuild when its price changes
final singleStockPriceProvider =
    Provider.family<PriceTick?, String>((ref, symbol) {
  final prices = ref.watch(marketPricesProvider);
  return prices[symbol];
});

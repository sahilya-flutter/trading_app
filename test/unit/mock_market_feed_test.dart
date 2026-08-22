import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/features/market/data/mock_market_feed.dart';
import 'package:trading_app/features/market/domain/price_tick.dart';

void main() {
  group('MockMarketFeed & PriceTick Tests', () {
    late MockMarketFeed feed;

    setUp(() {
      feed = MockMarketFeed();
    });

    tearDown(() {
      feed.dispose();
    });

    test('Initializes with all 10 stocks and valid starting prices', () {
      final ticks = feed.allCurrentTicks;
      expect(ticks.length, 10);
      for (final symbol in StockConstants.symbols) {
        expect(ticks.containsKey(symbol), isTrue);
        expect(ticks[symbol]!.ltpPaise, greaterThan(0));
        expect(ticks[symbol]!.previousClosePaise, greaterThan(0));
      }
    });

    test('Starting prices match StockConstants for all 10 universe stocks', () {
      for (final stock in StockConstants.initialStocks) {
        expect(feed.getLtpPaise(stock.symbol), stock.startingPricePaise);
      }
    });

    test('Tick rate can be dynamically updated and reflects in config', () {
      feed.setTickRate(10);
      expect(feed.ticksPerSecond, 10);

      feed.setTickRate(50);
      expect(feed.ticksPerSecond, 50);

      // Ignoring invalid zero or negative rates
      feed.setTickRate(0);
      expect(feed.ticksPerSecond, 50);
    });

    test('Emits ticks when started and stress mode can be toggled', () async {
      feed.setStressMode(true);
      expect(feed.isStressMode, isTrue);

      feed.start();
      expect(feed.isRunning, isTrue);

      final tick = await feed.tickStream.first;
      expect(tick, isA<PriceTick>());
      expect(StockConstants.symbols.contains(tick.symbol), isTrue);
      expect(tick.ltpPaise, greaterThanOrEqualTo(1000));
    });

    test('PriceTick JSON serialization and deserialization works correctly', () {
      final original = PriceTick(
        symbol: 'RELIANCE',
        ltpPaise: 298745,
        previousLtpPaise: 295000,
        deltaPaise: 3745,
        previousClosePaise: 295325,
        changePaise: 3420,
        changePercent: 1.16,
        timestamp: DateTime(2026, 8, 22, 12, 0),
        direction: TickDirection.up,
      );

      final json = original.toJson();
      expect(json['symbol'], 'RELIANCE');
      expect(json['ltpPaise'], 298745);
      expect(json['direction'], 'up');

      final restored = PriceTick.fromJson(json);
      expect(restored.symbol, original.symbol);
      expect(restored.ltpPaise, original.ltpPaise);
      expect(restored.direction, original.direction);
      expect(restored.isUp, isTrue);
      expect(restored.isPositive, isTrue);
    });

    test('PriceTick value equality works correctly', () {
      final tick1 = PriceTick.initial(
        symbol: 'TCS',
        startingPricePaise: 389210,
        previousClosePaise: 387960,
      );

      final tick2 = PriceTick.initial(
        symbol: 'TCS',
        startingPricePaise: 389210,
        previousClosePaise: 387960,
      );

      expect(tick1, equals(tick2));
      expect(tick1.hashCode, equals(tick2.hashCode));
    });
  });
}

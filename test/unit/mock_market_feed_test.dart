import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/features/market/data/mock_market_feed.dart';
import 'package:trading_app/features/market/domain/price_tick.dart';

void main() {
  group('MockMarketFeed Tests', () {
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
      }
    });

    test('Starting price matches StockConstants for RELIANCE and TCS', () {
      expect(feed.getLtpPaise('RELIANCE'), 142000);
      expect(feed.getLtpPaise('TCS'), 398000);
    });

    test('Emits ticks when started and stress mode can be toggled', () async {
      feed.setStressMode(true);
      expect(feed.isStressMode, isTrue);

      feed.start();
      expect(feed.isRunning, isTrue);

      final tick = await feed.tickStream.first;
      expect(tick, isA<PriceTick>());
      expect(StockConstants.symbols.contains(tick.symbol), isTrue);
      expect(tick.ltpPaise, greaterThan(0));
    });
  });
}

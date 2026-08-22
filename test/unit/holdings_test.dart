import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/stock_constants.dart';
import 'package:trading_app/features/holdings/domain/holding.dart';
import 'package:trading_app/features/holdings/presentation/holdings_providers.dart';
import 'package:trading_app/features/market/domain/price_tick.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Holding Model & Calculation Tests', () {
    test('Calculates invested value, current value, and P&L accurately in paise', () {
      // Holding 10 shares (10,000 units) at avg buy ₹1,400.00 (140,000 paise)
      const holding = Holding(
        symbol: 'RELIANCE',
        quantityUnits: 10000,
        averagePricePaise: 140000,
      );

      // Invested Value: 10 * 1400 = ₹14,000.00 (1,400,000 paise)
      expect(holding.investedValuePaise, 1400000);

      // If current LTP is ₹1,450.00 (145,000 paise)
      // Current Value: 10 * 1450 = ₹14,500.00 (1,450,000 paise)
      expect(holding.currentValuePaise(145000), 1450000);

      // P&L: 1,450,000 - 1,400,000 = +50,000 paise (+₹500.00)
      expect(holding.pnlPaise(145000), 50000);

      // P&L %: (50000 / 1400000) * 100 = 3.5714...%
      expect(holding.pnlPercent(145000), closeTo(3.57, 0.01));
    });

    test('Calculates loss correctly when LTP is lower than average price', () {
      const holding = Holding(
        symbol: 'TCS',
        quantityUnits: 5000, // 5 shares
        averagePricePaise: 400000, // ₹4000
      );

      // Invested = 5 * 4000 = ₹20,000 (2,000,000 paise)
      expect(holding.investedValuePaise, 2000000);

      // Current LTP = ₹3,900 (390,000 paise)
      // Current = 5 * 3900 = ₹19,500 (1,950,000 paise)
      expect(holding.currentValuePaise(390000), 1950000);

      // P&L = -50,000 paise (-₹500)
      expect(holding.pnlPaise(390000), -50000);

      // P&L % = -2.5%
      expect(holding.pnlPercent(390000), -2.5);
    });

    test('Zero invested value returns 0.0% P&L without division by zero or NaN', () {
      const zeroHolding = Holding(
        symbol: 'INFY',
        quantityUnits: 0,
        averagePricePaise: 150000,
      );

      expect(zeroHolding.investedValuePaise, 0);
      expect(zeroHolding.currentValuePaise(160000), 0);
      expect(zeroHolding.pnlPaise(160000), 0);
      expect(zeroHolding.pnlPercent(160000), 0.0);
    });
  });

  group('Portfolio Aggregate & Riverpod Integration Tests', () {
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

    test('Critical Aggregate Test (Section 40): Multi-holding sums equal total summary', () async {
      // 1. Setup multi-holdings in notifier
      final notifier = container.read(holdingsProvider.notifier);

      // RELIANCE: Invested = ₹10,000 (1,000,000 paise), 10 shares @ ₹1,000
      notifier.recordBuy(
        symbol: 'RELIANCE',
        quantityUnits: 10000,
        executionPricePaise: 100000,
      );

      // TCS: Invested = ₹20,000 (2,000,000 paise), 10 shares @ ₹2,000
      notifier.recordBuy(
        symbol: 'TCS',
        quantityUnits: 10000,
        executionPricePaise: 200000,
      );

      // INFY: Invested = ₹30,000 (3,000,000 paise), 10 shares @ ₹3,000
      notifier.recordBuy(
        symbol: 'INFY',
        quantityUnits: 10000,
        executionPricePaise: 300000,
      );

      // 2. Set current market prices via feed:
      // RELIANCE LTP = ₹1,100 -> Current = ₹11,000, P&L = +₹1,000
      // TCS LTP = ₹1,900 -> Current = ₹19,000, P&L = -₹1,000
      // INFY LTP = ₹3,300 -> Current = ₹33,000, P&L = +₹3,000
      final feed = container.read(marketFeedProvider);
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'RELIANCE',
        newLtpPaise: 110000,
        previousLtpPaise: 100000,
        previousClosePaise: 100000,
      ));
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'TCS',
        newLtpPaise: 190000,
        previousLtpPaise: 200000,
        previousClosePaise: 200000,
      ));
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'INFY',
        newLtpPaise: 330000,
        previousLtpPaise: 300000,
        previousClosePaise: 300000,
      ));

      await Future<void>.delayed(Duration.zero);

      // 3. Verify aggregate portfolio summary
      final summary = container.read(portfolioSummaryProvider);

      // Total Invested: ₹10,000 + ₹20,000 + ₹30,000 = ₹60,000 (6,000,000 paise)
      expect(summary.totalInvestedPaise, 6000000);

      // Total Current Value: ₹11,000 + ₹19,000 + ₹33,000 = ₹63,000 (6,300,000 paise)
      expect(summary.totalCurrentValuePaise, 6300000);

      // Total P&L: ₹63,000 - ₹60,000 = +₹3,000 (300,000 paise)
      expect(summary.totalPnlPaise, 300000);

      // Total P&L %: (300,000 / 6,000,000) * 100 = +5.0%
      expect(summary.totalPnlPercent, 5.0);
      expect(summary.totalHoldingsCount, 3);
    });

    test('Critical Live Sort Test (Section 41): P&L sort updates dynamically as prices change', () async {
      final notifier = container.read(holdingsProvider.notifier);
      final feed = container.read(marketFeedProvider);

      // RELIANCE: 1 share @ ₹1,000 (100,000 paise)
      notifier.recordBuy(
        symbol: 'RELIANCE',
        quantityUnits: 1000,
        executionPricePaise: 100000,
      );

      // TCS: 1 share @ ₹2,000 (200,000 paise)
      notifier.recordBuy(
        symbol: 'TCS',
        quantityUnits: 1000,
        executionPricePaise: 200000,
      );

      // Initial state:
      // RELIANCE LTP = ₹900 -> P&L = -₹100 (-10,000 paise)
      // TCS LTP = ₹2,050 -> P&L = +₹50 (+5,000 paise)
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'RELIANCE',
        newLtpPaise: 90000,
        previousLtpPaise: 100000,
        previousClosePaise: 100000,
      ));
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'TCS',
        newLtpPaise: 205000,
        previousLtpPaise: 200000,
        previousClosePaise: 200000,
      ));

      await Future<void>.delayed(Duration.zero);

      // With default P&L Descending sort: TCS (+₹50) should be first, RELIANCE (-₹100) second
      container.read(holdingsSortOptionProvider.notifier).state = HoldingsSortOption.pnlDesc;
      var sorted = container.read(sortedHoldingsProvider);
      expect(sorted[0].symbol, 'TCS');
      expect(sorted[1].symbol, 'RELIANCE');

      // Market updates RELIANCE price to ₹1,200 -> P&L = +₹200 (+20,000 paise)
      feed.emitTick(PriceTick.fromUpdate(
        symbol: 'RELIANCE',
        newLtpPaise: 120000,
        previousLtpPaise: 90000,
        previousClosePaise: 100000,
      ));

      await Future<void>.delayed(Duration.zero);

      // Automatically re-orders: RELIANCE (+₹200) first, TCS (+₹50) second
      sorted = container.read(sortedHoldingsProvider);
      expect(sorted[0].symbol, 'RELIANCE');
      expect(sorted[1].symbol, 'TCS');
    });

    test('All sorting options sort holdings deterministically', () async {
      final notifier = container.read(holdingsProvider.notifier);
      final feed = container.read(marketFeedProvider);

      notifier.recordBuy(symbol: 'TCS', quantityUnits: 1000, executionPricePaise: 200000);
      notifier.recordBuy(symbol: 'INFY', quantityUnits: 2000, executionPricePaise: 100000);
      notifier.recordBuy(symbol: 'AXISBANK', quantityUnits: 500, executionPricePaise: 50000);

      feed.emitTick(PriceTick.fromUpdate(symbol: 'TCS', newLtpPaise: 220000, previousLtpPaise: 200000, previousClosePaise: 200000)); // P&L = +20k, Val = 220k, Inv = 200k
      feed.emitTick(PriceTick.fromUpdate(symbol: 'INFY', newLtpPaise: 90000, previousLtpPaise: 100000, previousClosePaise: 100000)); // P&L = -20k, Val = 180k, Inv = 200k
      feed.emitTick(PriceTick.fromUpdate(symbol: 'AXISBANK', newLtpPaise: 60000, previousLtpPaise: 50000, previousClosePaise: 50000)); // P&L = +5k, Val = 30k, Inv = 25k

      await Future<void>.delayed(Duration.zero);

      // 1. Symbol Ascending (A-Z)
      container.read(holdingsSortOptionProvider.notifier).state = HoldingsSortOption.symbolAsc;
      var list = container.read(sortedHoldingsProvider);
      expect(list.map((h) => h.symbol).toList(), ['AXISBANK', 'INFY', 'TCS']);

      // 2. Current Value Descending
      container.read(holdingsSortOptionProvider.notifier).state = HoldingsSortOption.currentValueDesc;
      list = container.read(sortedHoldingsProvider);
      expect(list.map((h) => h.symbol).toList(), ['TCS', 'INFY', 'AXISBANK']);

      // 3. P&L Ascending (Lowest P&L first)
      container.read(holdingsSortOptionProvider.notifier).state = HoldingsSortOption.pnlAsc;
      list = container.read(sortedHoldingsProvider);
      expect(list.map((h) => h.symbol).toList(), ['INFY', 'AXISBANK', 'TCS']);
    });

    test('All 10 universe stocks held scenario computes correct portfolio and persists', () async {
      final notifier = container.read(holdingsProvider.notifier);

      for (final stock in StockConstants.initialStocks) {
        notifier.recordBuy(
          symbol: stock.symbol,
          quantityUnits: 1000,
          executionPricePaise: stock.startingPricePaise,
        );
      }

      final summary = container.read(portfolioSummaryProvider);
      expect(summary.totalHoldingsCount, 10);
      expect(summary.totalInvestedPaise, greaterThan(0));

      // Reload container to test persistence
      final freshStorage = await LocalStorageService.create();
      final freshContainer = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(freshStorage),
        ],
      );

      final freshHoldings = freshContainer.read(holdingsProvider);
      expect(freshHoldings.length, 10);
      for (final stock in StockConstants.initialStocks) {
        expect(freshHoldings.containsKey(stock.symbol), isTrue);
      }

      freshContainer.dispose();
    });
  });
}

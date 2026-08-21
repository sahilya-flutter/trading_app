import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../persistence/local_storage_service.dart';
import '../../market/presentation/market_providers.dart';
import '../domain/holding.dart';

enum HoldingsSortOption {
  pnlDesc('P&L High to Low'),
  pnlAsc('P&L Low to High'),
  symbolAsc('Symbol (A-Z)'),
  currentValueDesc('Value High to Low'),
  investedValueDesc('Invested High to Low');

  final String label;
  const HoldingsSortOption(this.label);
}

class HoldingsNotifier extends StateNotifier<Map<String, Holding>> {
  final LocalStorageService _storage;

  HoldingsNotifier(this._storage) : super(_storage.loadHoldings());

  void _persist() {
    _storage.saveHoldings(state);
  }

  void recordBuy({
    required String symbol,
    required int quantityUnits,
    required int executionPricePaise,
  }) {
    final existing = state[symbol];
    if (existing == null) {
      state = {
        ...state,
        symbol: Holding(
          symbol: symbol,
          quantityUnits: quantityUnits,
          averagePricePaise: executionPricePaise,
        ),
      };
    } else {
      final newTotalUnits = existing.quantityUnits + quantityUnits;
      final newAvgPrice = QuantityUtils.calculateNewAveragePricePaise(
        existingUnits: existing.quantityUnits,
        existingAvgPricePaise: existing.averagePricePaise,
        boughtUnits: quantityUnits,
        executionPricePaise: executionPricePaise,
      );

      state = {
        ...state,
        symbol: existing.copyWith(
          quantityUnits: newTotalUnits,
          averagePricePaise: newAvgPrice,
        ),
      };
    }
    _persist();
  }

  bool recordSell({
    required String symbol,
    required int quantityUnits,
  }) {
    final existing = state[symbol];
    if (existing == null || existing.quantityUnits < quantityUnits) {
      return false;
    }

    final remainingUnits = existing.quantityUnits - quantityUnits;
    if (remainingUnits <= 0) {
      // Remove holding completely
      final updated = Map<String, Holding>.from(state)..remove(symbol);
      state = updated;
    } else {
      state = {
        ...state,
        symbol: existing.copyWith(quantityUnits: remainingUnits),
      };
    }
    _persist();
    return true;
  }
}

final holdingsProvider =
    StateNotifierProvider<HoldingsNotifier, Map<String, Holding>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return HoldingsNotifier(storage);
});

final holdingsSortOptionProvider =
    StateProvider<HoldingsSortOption>((ref) => HoldingsSortOption.pnlDesc);

/// Aggregate portfolio summary
class PortfolioSummary {
  final int totalInvestedPaise;
  final int totalCurrentValuePaise;
  final int totalPnlPaise;
  final double totalPnlPercent;
  final int totalHoldingsCount;

  const PortfolioSummary({
    required this.totalInvestedPaise,
    required this.totalCurrentValuePaise,
    required this.totalPnlPaise,
    required this.totalPnlPercent,
    required this.totalHoldingsCount,
  });

  factory PortfolioSummary.zero() => const PortfolioSummary(
        totalInvestedPaise: 0,
        totalCurrentValuePaise: 0,
        totalPnlPaise: 0,
        totalPnlPercent: 0.0,
        totalHoldingsCount: 0,
      );
}

final portfolioSummaryProvider = Provider<PortfolioSummary>((ref) {
  final holdings = ref.watch(holdingsProvider).values;
  final prices = ref.watch(marketPricesProvider);

  if (holdings.isEmpty) return PortfolioSummary.zero();

  int totalInvested = 0;
  int totalCurrent = 0;

  for (final h in holdings) {
    final ltp = prices[h.symbol]?.ltpPaise ?? h.averagePricePaise;
    totalInvested += h.investedValuePaise;
    totalCurrent += h.currentValuePaise(ltp);
  }

  final totalPnl = totalCurrent - totalInvested;
  final totalPnlPct = totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0.0;

  return PortfolioSummary(
    totalInvestedPaise: totalInvested,
    totalCurrentValuePaise: totalCurrent,
    totalPnlPaise: totalPnl,
    totalPnlPercent: totalPnlPct,
    totalHoldingsCount: holdings.length,
  );
});

/// Dynamically sorted holdings list based on live prices
final sortedHoldingsProvider = Provider<List<Holding>>((ref) {
  final holdingsMap = ref.watch(holdingsProvider);
  final sortOption = ref.watch(holdingsSortOptionProvider);
  final prices = ref.watch(marketPricesProvider);

  final list = holdingsMap.values.toList();

  list.sort((a, b) {
    final priceA = prices[a.symbol]?.ltpPaise ?? a.averagePricePaise;
    final priceB = prices[b.symbol]?.ltpPaise ?? b.averagePricePaise;

    switch (sortOption) {
      case HoldingsSortOption.pnlDesc:
        return b.pnlPaise(priceB).compareTo(a.pnlPaise(priceA));
      case HoldingsSortOption.pnlAsc:
        return a.pnlPaise(priceA).compareTo(b.pnlPaise(priceB));
      case HoldingsSortOption.symbolAsc:
        return a.symbol.compareTo(b.symbol);
      case HoldingsSortOption.currentValueDesc:
        return b.currentValuePaise(priceB).compareTo(a.currentValuePaise(priceA));
      case HoldingsSortOption.investedValueDesc:
        return b.investedValuePaise.compareTo(a.investedValuePaise);
    }
  });

  return list;
});

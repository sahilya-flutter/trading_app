import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../market/presentation/market_providers.dart';
import '../watchlist_providers.dart';

class AddStockSheet extends ConsumerStatefulWidget {
  const AddStockSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (_) => const AddStockSheet(),
    );
  }

  @override
  ConsumerState<AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends ConsumerState<AddStockSheet> {
  final Set<String> _selectedSymbols = <String>{};

  void _toggleSelection(String symbol, bool isAlreadyInWatchlist) {
    if (isAlreadyInWatchlist) return; // Non-interactive

    setState(() {
      if (_selectedSymbols.contains(symbol)) {
        _selectedSymbols.remove(symbol);
      } else {
        _selectedSymbols.add(symbol);
      }
    });
  }

  void _handleAddStocks() {
    if (_selectedSymbols.isEmpty) return;

    for (final symbol in _selectedSymbols) {
      ref.read(watchlistProvider.notifier).addStockToActiveWatchlist(symbol);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activeWatchlist = ref.watch(activeWatchlistProvider);
    final existingSymbols = (activeWatchlist?.symbols ?? []).toSet();
    final allStocks = StockConstants.initialStocks;
    final selectedCount = _selectedSymbols.length;
    final hasSelection = selectedCount > 0;

    final sheetHeight = MediaQuery.of(context).size.height * 0.70;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag Pill
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Row: "Add stocks" in 17 semibold & close ✕
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add stocks',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // 1px divider under header
          const Divider(height: 1, thickness: 1, color: Color(0xFFECEFF2)),

          // Body: List of all 10 stocks, 56pt rows
          Expanded(
            child: ListView.separated(
              itemCount: allStocks.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, thickness: 1, color: Color(0xFFECEFF2)),
              itemBuilder: (context, index) {
                final stock = allStocks[index];
                final isAlreadyAdded = existingSymbols.contains(stock.symbol);
                final isSelected = _selectedSymbols.contains(stock.symbol);

                return Consumer(
                  builder: (context, ref, child) {
                    final tick =
                        ref.watch(singleStockPriceProvider(stock.symbol));
                    final ltpPaise =
                        tick?.ltpPaise ?? stock.startingPricePaise;

                    Widget rowContent = Container(
                      height: 56,
                      color: isSelected
                          ? const Color(0xFFF0F7FF) // Very faintly blue
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Symbol in 15 semibold, with tiny grey "NSE" under it
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stock.symbol,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'NSE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8E95A2),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Current price in tabular figures
                          Text(
                            MoneyFormatter.formatPaise(ltpPaise),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Selection control: 3 states
                          if (isAlreadyAdded)
                            // State 3: Already in watchlist (green tick icon)
                            const Icon(
                              Icons.check_circle,
                              size: 22,
                              color: Color(0xFF16A34A),
                            )
                          else if (isSelected)
                            // State 2: Selected (filled blue checkbox with white tick)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            )
                          else
                            // State 1: Unselected (empty rounded square checkbox in grey)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );

                    if (isAlreadyAdded) {
                      // Whole row at 40% opacity, non-interactive
                      return Opacity(
                        opacity: 0.40,
                        child: rowContent,
                      );
                    }

                    return InkWell(
                      onTap: () => _toggleSelection(stock.symbol, false),
                      child: rowContent,
                    );
                  },
                );
              },
            ),
          ),

          // 1px divider above footer
          const Divider(height: 1, thickness: 1, color: Color(0xFFECEFF2)),

          // Footer: Pinned above safe area, 52pt button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: hasSelection ? _handleAddStocks : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    disabledBackgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    hasSelection
                        ? (selectedCount == 1
                            ? 'Add 1 stock'
                            : 'Add $selectedCount stocks')
                        : 'Add stocks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasSelection
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

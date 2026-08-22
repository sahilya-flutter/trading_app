import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
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
    final colors = context.colors;

    final sheetHeight = MediaQuery.of(context).size.height * 0.70;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Drag Pill
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Row: "Add stocks" in 17 semibold & close ✕
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add stocks',
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: colors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // 1px divider under header
          Divider(height: 1, thickness: 1, color: colors.divider),

          // Body: List of all 10 stocks, 56pt rows
          Expanded(
            child: ListView.separated(
              itemCount: allStocks.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, thickness: 1, color: colors.divider),
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
                          ? colors.primaryContainer.withValues(alpha: 0.25)
                          : colors.surface,
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
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NSE',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Current price in tabular figures
                          Text(
                            MoneyFormatter.formatPaise(ltpPaise),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Selection control: 3 states
                          if (isAlreadyAdded)
                            // State 3: Already in watchlist (green tick icon)
                            Icon(
                              Icons.check_circle,
                              size: 22,
                              color: colors.gain,
                            )
                          else if (isSelected)
                            // State 2: Selected (filled blue checkbox with white tick)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: colors.onPrimary,
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
                                  color: colors.border,
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
          Divider(height: 1, thickness: 1, color: colors.divider),

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
                    backgroundColor: colors.primary,
                    disabledBackgroundColor: colors.chipBackground,
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
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasSelection
                          ? colors.onPrimary
                          : colors.textMuted,
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

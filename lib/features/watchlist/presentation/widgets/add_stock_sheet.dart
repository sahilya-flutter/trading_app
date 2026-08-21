import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../market/presentation/market_providers.dart';
import '../watchlist_providers.dart';

class AddStockSheet extends ConsumerStatefulWidget {
  const AddStockSheet({super.key});

  @override
  ConsumerState<AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends ConsumerState<AddStockSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWatchlist = ref.watch(activeWatchlistProvider);
    final existingSymbols = activeWatchlist?.symbols ?? [];

    final filtered = StockConstants.initialStocks.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.symbol.toLowerCase().contains(q) ||
          s.companyName.toLowerCase().contains(q);
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Stocks to ${activeWatchlist?.name ?? "Watchlist"}',
                  style: AppTextStyles.headingSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search stocks to add...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
          ),

          const Divider(),

          // Stocks List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final stock = filtered[index];
                final isAdded = existingSymbols.contains(stock.symbol);

                return Consumer(
                  builder: (context, ref, child) {
                    final tick = ref.watch(singleStockPriceProvider(stock.symbol));
                    final ltpPaise = tick?.ltpPaise ?? stock.startingPricePaise;

                    return ListTile(
                      title: Text(stock.symbol, style: AppTextStyles.labelLarge),
                      subtitle: Text(stock.companyName, style: AppTextStyles.bodySmall),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            MoneyFormatter.formatPaise(ltpPaise),
                            style: AppTextStyles.monoNumbers,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              isAdded ? Icons.check_circle : Icons.add_circle_outline,
                              color: isAdded ? AppColors.gain : AppColors.primary,
                            ),
                            onPressed: () {
                              if (isAdded) {
                                ref
                                    .read(watchlistProvider.notifier)
                                    .removeStockFromActiveWatchlist(stock.symbol);
                              } else {
                                ref
                                    .read(watchlistProvider.notifier)
                                    .addStockToActiveWatchlist(stock.symbol);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'watchlist_providers.dart';
import 'widgets/add_stock_sheet.dart';
import 'widgets/watchlist_row.dart';
import 'widgets/watchlist_selector_sheet.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  void _openWatchlistSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WatchlistSelectorSheet(),
    );
  }

  void _openAddStockSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddStockSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWatchlist = ref.watch(activeWatchlistProvider);
    final symbols = activeWatchlist?.symbols ?? [];

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _openWatchlistSelector(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    activeWatchlist?.name ?? 'Watchlist',
                    style: AppTextStyles.headingSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primaryLight),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryLight),
            tooltip: 'Add Stock',
            onPressed: () => _openAddStockSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined, color: AppColors.textSecondary),
            tooltip: 'Manage Watchlists',
            onPressed: () => _openWatchlistSelector(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${symbols.length} stocks in this list',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Hold drag icon to reorder',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(),

          // Body
          Expanded(
            child: symbols.isEmpty
                ? EmptyStateView(
                    icon: Icons.bookmark_border,
                    title: 'Your watchlist is empty',
                    message: 'Add stocks from the market universe to track prices and trade easily.',
                    buttonText: '+ Add Stock',
                    onButtonPressed: () => _openAddStockSheet(context),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: symbols.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(watchlistProvider.notifier)
                          .reorderActiveWatchlist(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final symbol = symbols[index];
                      return Column(
                        key: ValueKey('watchlist_row_$symbol'),
                        children: [
                          WatchlistRow(
                            key: ValueKey('row_$symbol'),
                            symbol: symbol,
                            index: index,
                            onTap: () {
                              context.push('/order?symbol=$symbol');
                            },
                            onRemove: () {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .removeStockFromActiveWatchlist(symbol);
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: symbols.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _openAddStockSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

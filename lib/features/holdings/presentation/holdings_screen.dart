import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'holdings_providers.dart';
import 'widgets/holding_row.dart';
import 'widgets/portfolio_summary_card.dart';

class HoldingsScreen extends ConsumerWidget {
  const HoldingsScreen({super.key});

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(holdingsSortOptionProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sort Holdings By', style: AppTextStyles.headingSmall),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            ...HoldingsSortOption.values.map((option) {
              final isSelected = option == currentSort;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  ref.read(holdingsSortOptionProvider.notifier).state = option;
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(sortedHoldingsProvider);
    final currentSort = ref.watch(holdingsSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holdings & Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.textSecondary),
            tooltip: 'Sort Holdings',
            onPressed: () => _showSortSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Portfolio Summary Header Card
          const PortfolioSummaryCard(),

          // Section Title & Sort Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Positions (${holdings.length})',
                  style: AppTextStyles.labelLarge,
                ),
                InkWell(
                  onTap: () => _showSortSheet(context, ref),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          currentSort.label,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primaryLight),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Holdings List
          Expanded(
            child: holdings.isEmpty
                ? EmptyStateView(
                    icon: Icons.pie_chart_outline,
                    title: 'No Active Holdings',
                    message:
                        'You do not have any open stock positions yet. Place a Buy order from the Market or Watchlist.',
                    buttonText: 'Explore Market',
                    onButtonPressed: () => context.go('/market'),
                  )
                : ListView.separated(
                    itemCount: holdings.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final holding = holdings[index];
                      return HoldingRow(
                        key: ValueKey('holding_${holding.symbol}'),
                        holding: holding,
                        onTap: () {
                          context.push('/order?symbol=${holding.symbol}');
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

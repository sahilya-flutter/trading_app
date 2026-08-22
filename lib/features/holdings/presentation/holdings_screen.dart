import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/trading_app_bar.dart';
import 'holdings_providers.dart';
import 'widgets/holding_row.dart';
import 'widgets/portfolio_summary_card.dart';

class HoldingsScreen extends ConsumerWidget {
  const HoldingsScreen({super.key});

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(holdingsSortOptionProvider);
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: colors.border),
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
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort Holdings By',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: colors.divider),
            ...HoldingsSortOption.values.map((option) {
              final isSelected = option == currentSort;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? colors.primary : colors.textMuted,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.textPrimary : colors.textSecondary,
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
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(sortedHoldingsProvider);
    final currentSort = ref.watch(holdingsSortOptionProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: TradingAppBar.holdings(
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: colors.textSecondary, size: 22),
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
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                  ),
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
                          style: AppTextStyles.bodySmall.copyWith(color: colors.primaryLight),
                        ),
                        Icon(Icons.arrow_drop_down, size: 16, color: colors.primaryLight),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.divider),

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
                    separatorBuilder: (context, index) => Divider(color: colors.divider),
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

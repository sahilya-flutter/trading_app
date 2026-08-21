import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/price_flash_widget.dart';
import '../../../market/presentation/market_providers.dart';

class WatchlistRow extends ConsumerWidget {
  final String symbol;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const WatchlistRow({
    required Key key,
    required this.symbol,
    required this.index,
    this.onTap,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Symbol-specific price subscription (independent of list index/position)
    final tick = ref.watch(singleStockPriceProvider(symbol));
    final stock = StockConstants.stockMap[symbol];

    final ltpPaise = tick?.ltpPaise ?? stock?.startingPricePaise ?? 0;
    final changePaise = tick?.changePaise ??
        ((stock?.startingPricePaise ?? 0) - (stock?.previousClosePaise ?? 0));
    final changePercent = tick?.changePercent ??
        ((stock?.previousClosePaise ?? 0) > 0
            ? (changePaise / stock!.previousClosePaise) * 100
            : 0.0);

    final isPositive = changePaise >= 0;
    final badgeColor = isPositive ? AppColors.gain : AppColors.loss;
    final badgeBg = isPositive ? AppColors.gainBg : AppColors.lossBg;
    final badgeBorder = isPositive ? AppColors.gainBorder : AppColors.lossBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: PriceFlashWidget(
          tick: tick,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drag Handle
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColors.textDisabled,
                    size: 20,
                  ),
                ),
              ),

              // Symbol & Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock?.companyName ?? '',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Price & Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormatter.formatPaise(ltpPaise),
                    style: AppTextStyles.monoNumbers,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: badgeBorder, width: 0.5),
                    ),
                    child: Text(
                      '${MoneyFormatter.formatPaiseWithSign(changePaise)} (${MoneyFormatter.formatPercent(changePercent)})',
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),

              // Remove Action
              if (onRemove != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove from watchlist',
                  padding: const EdgeInsets.only(left: 8),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/price_flash_widget.dart';
import '../../domain/stock.dart';
import '../market_providers.dart';

class MarketPriceRow extends ConsumerWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const MarketPriceRow({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when this specific stock tick updates!
    final tick = ref.watch(singleStockPriceProvider(stock.symbol));

    final ltpPaise = tick?.ltpPaise ?? stock.startingPricePaise;
    final changePaise = tick?.changePaise ?? (stock.startingPricePaise - stock.previousClosePaise);
    final changePercent = tick?.changePercent ??
        (stock.previousClosePaise > 0
            ? ((stock.startingPricePaise - stock.previousClosePaise) / stock.previousClosePaise) * 100
            : 0.0);

    final isPositive = changePaise >= 0;
    final badgeColor = isPositive ? AppColors.gain : AppColors.loss;
    final badgeBg = isPositive ? AppColors.gainBg : AppColors.lossBg;
    final badgeBorder = isPositive ? AppColors.gainBorder : AppColors.lossBorder;

    return InkWell(
      onTap: onTap,
      child: PriceFlashWidget(
        tick: tick,
        borderRadius: BorderRadius.circular(0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Symbol & Company
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.companyName,
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
          ],
        ),
      ),
    );
  }
}

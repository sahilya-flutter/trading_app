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
    final colors = context.colors;

    final ltpPaise = tick?.ltpPaise ?? stock.startingPricePaise;
    final changePaise = tick?.changePaise ?? (stock.startingPricePaise - stock.previousClosePaise);
    final changePercent = tick?.changePercent ??
        (stock.previousClosePaise > 0
            ? ((stock.startingPricePaise - stock.previousClosePaise) / stock.previousClosePaise) * 100
            : 0.0);

    final isPositive = changePaise >= 0;
    final badgeColor = isPositive ? colors.gain : colors.loss;
    final badgeBg = isPositive ? colors.gainBg : colors.lossBg;
    final badgeBorder = isPositive ? colors.gainBorder : colors.lossBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.companyName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
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
                    style: AppTextStyles.monoNumbers.copyWith(
                      color: colors.textPrimary,
                    ),
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
                        fontFamily: 'JetBrains Mono',
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/quantity_utils.dart';
import '../../../../core/widgets/price_flash_widget.dart';
import '../../../market/presentation/market_providers.dart';
import '../../domain/holding.dart';

class HoldingRow extends ConsumerWidget {
  final Holding holding;
  final VoidCallback? onTap;

  const HoldingRow({
    required Key key,
    required this.holding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(singleStockPriceProvider(holding.symbol));
    final colors = context.colors;

    final ltpPaise = tick?.ltpPaise ?? holding.averagePricePaise;

    final currentPaise = holding.currentValuePaise(ltpPaise);
    final pnlPaise = holding.pnlPaise(ltpPaise);
    final pnlPct = holding.pnlPercent(ltpPaise);

    final isProfit = pnlPaise >= 0;
    final badgeColor = isProfit ? colors.gain : colors.loss;
    final badgeBg = isProfit ? colors.gainBg : colors.lossBg;
    final badgeBorder = isProfit ? colors.gainBorder : colors.lossBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: PriceFlashWidget(
          tick: tick,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Symbol & Quantity / Avg Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          holding.symbol,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${QuantityUtils.formatQuantity(holding.quantityUnits, trimTrailingZeros: true)} Qty',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avg: ${MoneyFormatter.formatPaise(holding.averagePricePaise)}  •  LTP: ${MoneyFormatter.formatPaise(ltpPaise)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // P&L and Current Value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormatter.formatPaise(currentPaise),
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
                      '${MoneyFormatter.formatPaiseWithSign(pnlPaise)} (${MoneyFormatter.formatPercent(pnlPct)})',
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

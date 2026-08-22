import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../market/presentation/market_providers.dart';

class WatchlistRow extends ConsumerWidget {
  final String symbol;
  final int index;
  final VoidCallback? onTap;

  const WatchlistRow({
    required Key key,
    required this.symbol,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(singleStockPriceProvider(symbol));
    final stock = StockConstants.stockMap[symbol];
    final colors = context.colors;

    final ltpPaise = tick?.ltpPaise ?? stock?.startingPricePaise ?? 0;
    final changePaise = tick?.changePaise ??
        ((stock?.startingPricePaise ?? 0) - (stock?.previousClosePaise ?? 0));
    final changePercent = tick?.changePercent ??
        ((stock?.previousClosePaise ?? 0) > 0
            ? (changePaise / stock!.previousClosePaise) * 100
            : 0.0);

    final isPositive = changePaise >= 0;
    final changeColor = isPositive ? colors.gain : colors.loss;

    final arrow = isPositive ? '↑' : '↓';
    final sign = isPositive ? '+' : '-';
    final changeValStr =
        MoneyFormatter.formatPaise(changePaise.abs()).replaceAll('₹', '');
    final percentStr = MoneyFormatter.formatPercent(changePercent.abs());
    final formattedChange = '$arrow $sign$changeValStr ($sign$percentStr)';

    final priceStr = MoneyFormatter.formatPaise(ltpPaise).replaceAll('₹', '');

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Drag-handle icon (six dots) on far left
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_indicator,
                    color: colors.textDisabled,
                    size: 20,
                  ),
                ),
              ),

              // Symbol in 16 semibold with NSE badge right next to it
              Expanded(
                child: Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NSE',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price in 16 semibold (tabular figures), and absolute & % change on one line with arrow
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    priceStr,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedChange,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: changeColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

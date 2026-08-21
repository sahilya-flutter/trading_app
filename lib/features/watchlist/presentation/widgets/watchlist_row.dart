import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final ltpPaise = tick?.ltpPaise ?? stock?.startingPricePaise ?? 0;
    final changePaise = tick?.changePaise ??
        ((stock?.startingPricePaise ?? 0) - (stock?.previousClosePaise ?? 0));
    final changePercent = tick?.changePercent ??
        ((stock?.previousClosePaise ?? 0) > 0
            ? (changePaise / stock!.previousClosePaise) * 100
            : 0.0);

    final isPositive = changePaise >= 0;
    final changeColor = isPositive
        ? const Color(0xFF16A34A) // Green if up
        : const Color(0xFFDC2626); // Red if down

    final formattedChange =
        '${MoneyFormatter.formatPaiseWithSign(changePaise)} (${MoneyFormatter.formatPercent(changePercent)})';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Faint grey drag-handle icon (six dots) on far left
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.drag_indicator,
                      color: Color(0xFFC4C8D0), // Faint grey
                      size: 20,
                    ),
                  ),
                ),

                // Symbol in 15 semibold, with tiny grey "NSE" label under it
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'NSE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E95A2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price in 15 semibold (tabular figures), and absolute & % change on one line
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormatter.formatPaise(ltpPaise),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        fontFeatures: [FontFeature.tabularFigures()],
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedChange,
                      style: TextStyle(
                        fontSize: 12,
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
      ),
    );
  }
}

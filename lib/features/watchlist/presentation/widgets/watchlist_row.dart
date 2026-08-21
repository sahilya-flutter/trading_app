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

    final arrow = isPositive ? '↑' : '↓';
    final sign = isPositive ? '+' : '-';
    final changeValStr =
        MoneyFormatter.formatPaise(changePaise.abs()).replaceAll('₹', '');
    final percentStr = MoneyFormatter.formatPercent(changePercent.abs());
    final formattedChange = '$arrow $sign$changeValStr ($sign$percentStr)';

    final priceStr = MoneyFormatter.formatPaise(ltpPaise).replaceAll('₹', '');

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64,
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
                    color: Color(0xFFCBD5E1), // Faint grey 6-dots
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0E1621),
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
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NSE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E1621),
                      fontFeatures: [FontFeature.tabularFigures()],
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedChange,
                    style: TextStyle(
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

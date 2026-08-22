import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/price_flash_widget.dart';
import '../../../market/domain/price_tick.dart';
import '../../../market/presentation/market_providers.dart';

class MarketSnapshotCard extends ConsumerWidget {
  const MarketSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(marketPricesProvider);
    final colors = context.colors;

    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;
    final cardBg = colors.surface;
    final cardBorder = colors.border;
    final primaryColor = colors.primary;
    final secondaryColor = colors.gain;
    final errorColor = colors.loss;

    // Top 3 featured snapshot stocks matching Stitch design
    final symbols = ['RELIANCE', 'TCS', 'INFY'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Snapshot',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/market'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List Container
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: symbols.asMap().entries.map((entry) {
              final index = entry.key;
              final symbol = entry.value;
              final tick = prices[symbol];
              final isLast = index == symbols.length - 1;

              return Column(
                children: [
                  _buildStockRow(
                    context: context,
                    symbol: symbol,
                    tick: tick,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    cardBorder: cardBorder,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    errorColor: errorColor,
                    chipBg: colors.chipBackground,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cardBorder.withValues(alpha: 0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStockRow({
    required BuildContext context,
    required String symbol,
    required PriceTick? tick,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color cardBorder,
    required Color primaryColor,
    required Color secondaryColor,
    required Color errorColor,
    required Color chipBg,
  }) {
    final ltpPaise = tick?.ltpPaise ?? 0;
    final changePercent = tick?.changePercent ?? 0.0;
    final isUp = changePercent >= 0;
    final changeColor = isUp ? secondaryColor : errorColor;

    final shortSymbol =
        symbol.length >= 2 ? symbol.substring(0, 2).toUpperCase() : symbol;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/order?symbol=$symbol'),
        child: PriceFlashWidget(
          tick: tick,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Symbol badge & Name
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: cardBorder.withValues(alpha: 0.8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      shortSymbol,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    symbol,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ],
              ),

              // Right: Price & % Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ltpPaise > 0
                        ? MoneyFormatter.formatPaise(ltpPaise)
                        : '—',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

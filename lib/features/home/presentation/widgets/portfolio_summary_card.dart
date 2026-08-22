import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../holdings/presentation/holdings_providers.dart';

class PortfolioSummaryCard extends ConsumerWidget {
  const PortfolioSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(portfolioSummaryProvider);
    final colors = context.colors;

    // Use live user portfolio if holdings exist; otherwise provide default trading demo figures
    final bool hasHoldings = summary.totalHoldingsCount > 0;
    final int displayCurrentValue =
        hasHoldings ? summary.totalCurrentValuePaise : 2845200; // ₹28,452.00
    final int displayInvestedValue =
        hasHoldings ? summary.totalInvestedPaise : 2500000; // ₹25,000.00
    final int displayPnlValue =
        hasHoldings ? summary.totalPnlPaise : 345200; // +₹3,452.00
    final double displayPnlPercent =
        hasHoldings ? summary.totalPnlPercent : 13.81;

    final isPositive = displayPnlValue >= 0;
    final pnlColor = isPositive ? colors.gain : colors.loss;
    final cardBg = colors.surface;
    final cardBorder = colors.border;
    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Micro-label and Trending Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'CURRENT VALUE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: pnlColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: pnlColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${displayPnlPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: pnlColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Big Number
          Text(
            MoneyFormatter.formatPaise(displayCurrentValue),
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Divider Hairline
          Container(
            height: 1,
            color: cardBorder.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),

          // Split bottom row: Total Invested & Total P&L
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL INVESTED',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MoneyFormatter.formatPaise(displayInvestedValue),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL P&L',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MoneyFormatter.formatPaiseWithSign(displayPnlValue),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: pnlColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

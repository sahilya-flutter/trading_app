import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../wallet/presentation/wallet_providers.dart';
import '../holdings_providers.dart';

class PortfolioSummaryCard extends ConsumerWidget {
  const PortfolioSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(portfolioSummaryProvider);
    final walletBalance = ref.watch(walletBalancePaiseProvider);

    final isProfit = summary.totalPnlPaise >= 0;
    final pnlColor = isProfit ? AppColors.gain : AppColors.loss;
    final pnlBg = isProfit ? AppColors.gainBg : AppColors.lossBg;
    final pnlBorder = isProfit ? AppColors.gainBorder : AppColors.lossBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Portfolio Value Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Current Value', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    MoneyFormatter.formatPaise(summary.totalCurrentValuePaise),
                    style: AppTextStyles.headingLarge.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // Overall P&L Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pnlBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pnlBorder, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormatter.formatPaiseWithSign(summary.totalPnlPaise),
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      MoneyFormatter.formatPercent(summary.totalPnlPercent),
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Bottom Stats (Invested vs Cash)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Invested', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      MoneyFormatter.formatPaise(summary.totalInvestedPaise),
                      style: AppTextStyles.monoNumbers,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Cash', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      MoneyFormatter.formatPaise(walletBalance),
                      style: AppTextStyles.monoNumbers.copyWith(color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

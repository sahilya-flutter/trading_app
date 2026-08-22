import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/stock_constants.dart';
import 'wallet_funds_sheet.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  void _showStockSelectDialog(BuildContext context, {required bool isBuy}) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogBg = isDark ? AppColors.stitchSurfaceContainer : Colors.white;
        final onSurface = isDark ? AppColors.stitchOnSurface : const Color(0xFF0E1621);
        final onSurfaceVariant = isDark ? AppColors.stitchOnSurfaceVariant : const Color(0xFF65707D);
        final outlineVariant = isDark ? AppColors.stitchOutlineVariant : const Color(0xFFE2E8F0);

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outlineVariant),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          title: Text(
            isBuy ? 'Select Stock to Buy' : 'Select Stock to Sell',
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: StockConstants.initialStocks.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final stock = StockConstants.initialStocks[index];
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.stitchSurface : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: outlineVariant),
                    ),
                    child: Text(
                      stock.symbol.substring(0, stock.symbol.length >= 2 ? 2 : 1),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.stitchPrimary : const Color(0xFF1F4FD8),
                      ),
                    ),
                  ),
                  title: Text(
                    stock.symbol,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  subtitle: Text(
                    stock.companyName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push('/order?symbol=${stock.symbol}');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final secondaryBg = isDark ? AppColors.darkGain : AppColors.lightGain;
    final onSecondary = isDark ? AppColors.darkOnPrimary : Colors.white;

    final errorBg = isDark ? AppColors.darkLoss : AppColors.lightLoss;
    final onError = isDark ? AppColors.stitchOnError : Colors.white;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final onSurfaceVariant = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryIconColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // 1. Buy Button
            Expanded(
              child: _buildActionButton(
                label: 'Buy',
                icon: Icons.add_circle,
                bgColor: secondaryBg,
                fgColor: onSecondary,
                onTap: () => _showStockSelectDialog(context, isBuy: true),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Sell Button
            Expanded(
              child: _buildActionButton(
                label: 'Sell',
                icon: Icons.remove_circle,
                bgColor: errorBg,
                fgColor: onError,
                onTap: () => _showStockSelectDialog(context, isBuy: false),
              ),
            ),
            const SizedBox(width: 8),

            // 3. Holdings Button
            Expanded(
              child: _buildTonalButton(
                label: 'Holdings',
                icon: Icons.pie_chart,
                iconColor: primaryIconColor,
                bgColor: cardBg,
                borderColor: cardBorder,
                textColor: onSurfaceVariant,
                onTap: () => context.go('/holdings'),
              ),
            ),
            const SizedBox(width: 8),

            // 4. Wallet Button
            Expanded(
              child: _buildTonalButton(
                label: 'Wallet',
                icon: Icons.account_balance_wallet,
                iconColor: primaryIconColor,
                bgColor: cardBg,
                borderColor: cardBorder,
                textColor: onSurfaceVariant,
                onTap: () => WalletFundsSheet.show(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fgColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTonalButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

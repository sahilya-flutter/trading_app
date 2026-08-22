import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../wallet/presentation/wallet_providers.dart';

class WalletFundsSheet extends ConsumerWidget {
  const WalletFundsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletFundsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancePaise = ref.watch(walletBalancePaiseProvider);
    final colors = context.colors;

    final sheetBg = colors.surface;
    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;
    final outlineVariant = colors.border;
    final primaryColor = colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: outlineVariant, width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet & Funds',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: onSurfaceVariant, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Available Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outlineVariant, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE TRADING BALANCE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  MoneyFormatter.formatPaise(balancePaise),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add Demo Funds Quick Buttons
          Text(
            'ADD DEMO FUNDS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAddFundsButton(context, ref, '+ ₹10,000', 1000000),
              const SizedBox(width: 8),
              _buildAddFundsButton(context, ref, '+ ₹50,000', 5000000),
              const SizedBox(width: 8),
              _buildAddFundsButton(context, ref, '+ ₹1,00,000', 10000000),
            ],
          ),
          const SizedBox(height: 16),

          // Reset balance option
          Center(
            child: TextButton.icon(
              onPressed: () {
                ref.read(walletProvider.notifier).reset();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet reset to ₹1,00,000.00'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.refresh, size: 16, color: primaryColor),
              label: Text(
                'Reset Default Balance (₹1,00,000)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFundsButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    int paise,
  ) {
    final colors = context.colors;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          ref.read(walletProvider.notifier).credit(paise);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $label to trading wallet'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

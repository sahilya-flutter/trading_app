import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/quantity_utils.dart';
import '../../../order/domain/order_model.dart';
import '../../../order/domain/order_side.dart';
import '../../../order/presentation/order_providers.dart';

class RecentOrdersList extends ConsumerWidget {
  const RecentOrdersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final onSurface = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final onSurfaceVariant = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryColor = isDark ? AppColors.darkGain : AppColors.lightGain;
    final errorColor = isDark ? AppColors.darkLoss : AppColors.lightLoss;

    // If no real orders yet, we show the default Stitch demo completed order
    final hasRealOrders = orders.isNotEmpty;
    final recentOrders = hasRealOrders ? orders.take(3).toList() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Recent Orders',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 10),

        if (recentOrders != null)
          ...recentOrders.map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildOrderCard(
                context: context,
                order: order,
                cardBg: cardBg,
                cardBorder: cardBorder,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
                secondaryColor: secondaryColor,
                errorColor: errorColor,
              ),
            );
          })
        else
          // Default Stitch Demo Order Card
          _buildDemoOrderCard(
            context: context,
            cardBg: cardBg,
            cardBorder: cardBorder,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            secondaryColor: secondaryColor,
          ),
      ],
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required OrderModel order,
    required Color cardBg,
    required Color cardBorder,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color secondaryColor,
    required Color errorColor,
  }) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? secondaryColor : errorColor;
    final qtyFormatted = QuantityUtils.formatQuantity(order.quantityUnits, trimTrailingZeros: true);

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/order?symbol=${order.symbol}'),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Top Row: Side badge, Symbol, Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: sideColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: sideColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isBuy ? 'BUY' : 'SELL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: sideColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.symbol,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bottom Row: Qty @ Price, Total Value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty: $qtyFormatted',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '@ ${MoneyFormatter.formatPaise(order.executionPricePaise)}',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    MoneyFormatter.formatPaise(order.orderValuePaise),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
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

  Widget _buildDemoOrderCard({
    required BuildContext context,
    required Color cardBg,
    required Color cardBorder,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color secondaryColor,
  }) {
    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/order?symbol=HDFCBANK'),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: secondaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HDFCBANK',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty: 15',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '@ ₹1,645.00',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹24,675.00',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
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

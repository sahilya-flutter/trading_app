import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../core/widgets/trading_app_bar.dart';
import '../domain/order_side.dart';
import 'order_providers.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderHistoryProvider);
    final colors = context.colors;

    final textDark = colors.textPrimary;
    final textGrey = colors.textSecondary;
    final borderGrey = colors.border;
    final cardBg = colors.surfaceElevated;
    final hairline = colors.divider;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: TradingAppBar.secondary(
        title: 'Order History',
      ),
      body: SafeArea(
        child: orders.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isBuy = order.side == OrderSide.buy;
                  final sideColor = isBuy ? colors.gain : colors.loss;
                  final sideBg = sideColor.withValues(alpha: 0.12);
                  final formattedDate =
                      DateFormat('dd MMM yyyy · hh:mm a').format(order.timestamp);
                  final qtyStr = QuantityUtils.formatQuantity(order.quantityUnits);
                  final priceStr =
                      MoneyFormatter.formatPaise(order.executionPricePaise);
                  final valueStr =
                      MoneyFormatter.formatPaise(order.orderValuePaise);

                  return InkWell(
                    onTap: () => context.push('/order?symbol=${order.symbol}'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderGrey, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Side badge + Symbol, and Order Value
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sideBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isBuy ? 'BUY' : 'SELL',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: sideColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.symbol,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                valueStr,
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Divider(height: 1, thickness: 1, color: hairline),
                          const SizedBox(height: 10),

                          // Middle Row: Quantity & Execution Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$qtyStr shares @ $priceStr',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textGrey,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colors.gain,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.gain,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Bottom Row: Timestamp
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.chipBackground,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your completed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => context.go('/market'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Explore Markets',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

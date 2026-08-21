import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/quantity_utils.dart';
import '../domain/order_model.dart';
import '../domain/order_side.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final themeColor = isBuy ? AppColors.gain : AppColors.loss;
    final timeFormatted =
        DateFormat('dd MMM yyyy, hh:mm:ss a').format(order.timestamp);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/market'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Success Circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 2),
              ),
              child: Icon(Icons.check, size: 48, color: themeColor),
            ),

            const SizedBox(height: 20),

            Text(
              'Order Executed Successfully!',
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${order.side.displayName} order for ${order.symbol} has been executed at market LTP.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Receipt Card
            Card(
              color: AppColors.surfaceElevated,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Action / Side', style: AppTextStyles.bodyMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBuy ? AppColors.gainBg : AppColors.lossBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isBuy ? AppColors.gainBorder : AppColors.lossBorder,
                            ),
                          ),
                          child: Text(
                            order.side.displayName,
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _ReceiptRow(label: 'Stock Symbol', value: order.symbol),
                    const SizedBox(height: 12),
                    _ReceiptRow(
                      label: 'Executed Quantity',
                      value: '${QuantityUtils.formatQuantity(order.quantityUnits)} Shares',
                    ),
                    const SizedBox(height: 12),
                    _ReceiptRow(
                      label: 'Execution Price',
                      value: MoneyFormatter.formatPaise(order.executionPricePaise),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Order Value', style: AppTextStyles.labelLarge),
                        Text(
                          MoneyFormatter.formatPaise(order.orderValuePaise),
                          style: AppTextStyles.monoNumbersLarge.copyWith(color: themeColor),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _ReceiptRow(label: 'Execution Time', value: timeFormatted),
                    const SizedBox(height: 12),
                    _ReceiptRow(
                      label: 'Order ID',
                      value: order.id.substring(0, 8).toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/holdings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Holdings', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/market'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Market', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

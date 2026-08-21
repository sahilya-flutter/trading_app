import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../core/widgets/price_flash_widget.dart';
import '../../holdings/presentation/holdings_providers.dart';
import '../../market/domain/stock.dart';
import '../../market/presentation/market_providers.dart';
import '../../wallet/presentation/wallet_providers.dart';
import '../domain/order_side.dart';
import 'order_providers.dart';

class OrderTicketScreen extends ConsumerStatefulWidget {
  final String symbol;

  const OrderTicketScreen({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<OrderTicketScreen> createState() => _OrderTicketScreenState();
}

class _OrderTicketScreenState extends ConsumerState<OrderTicketScreen> {
  OrderSide _selectedSide = OrderSide.buy;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  String? _validationError;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _onSideChanged(OrderSide side) {
    setState(() {
      _selectedSide = side;
      _validationError = null;
    });
  }

  void _setQuantity(double qty) {
    setState(() {
      _qtyController.text = qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
      _validationError = null;
    });
  }

  void _addQuantity(double add) {
    final currentUnits = QuantityUtils.parseQuantityToUnits(_qtyController.text) ?? 0;
    final currentQty = currentUnits / 1000.0;
    final newQty = currentQty + add;
    _setQuantity(newQty);
  }

  void _submitOrder() {
    final qtyText = _qtyController.text.trim();
    final quantityUnits = QuantityUtils.parseQuantityToUnits(qtyText);

    if (quantityUnits == null || quantityUnits <= 0) {
      setState(() {
        _validationError = 'Please enter a valid positive quantity (max 3 decimal places)';
      });
      return;
    }

    final result = ref.read(orderHistoryProvider.notifier).executeOrder(
          symbol: widget.symbol,
          side: _selectedSide,
          quantityUnits: quantityUnits,
        );

    if (!result.isSuccess) {
      setState(() {
        _validationError = result.errorMessage ?? 'Order execution failed';
      });
    } else {
      // Navigate to order confirmation
      final order = result.order!;
      context.pushReplacement(
        '/order/confirmation',
        extra: order,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = StockConstants.stockMap[widget.symbol] ??
        Stock(
          symbol: widget.symbol,
          companyName: widget.symbol,
          startingPricePaise: 10000,
          previousClosePaise: 10000,
        );

    // Live tick for selected stock
    final tick = ref.watch(singleStockPriceProvider(widget.symbol));
    final ltpPaise = tick?.ltpPaise ?? stock.startingPricePaise;
    final changePaise = tick?.changePaise ?? (stock.startingPricePaise - stock.previousClosePaise);
    final changePercent = tick?.changePercent ?? 0.0;

    // Available cash balance
    final balancePaise = ref.watch(walletBalancePaiseProvider);

    // Holdings for this symbol
    final holdings = ref.watch(holdingsProvider);
    final holding = holdings[widget.symbol];
    final heldUnits = holding?.quantityUnits ?? 0;

    // Parse entered quantity
    final parsedUnits = QuantityUtils.parseQuantityToUnits(_qtyController.text);
    final projectedValuePaise = parsedUnits != null
        ? QuantityUtils.calculateOrderValuePaise(parsedUnits, ltpPaise)
        : 0;

    final isBuy = _selectedSide == OrderSide.buy;
    final themeColor = isBuy ? AppColors.gain : AppColors.loss;

    // Live inline validation check
    String? liveWarning;
    if (parsedUnits != null && parsedUnits > 0) {
      if (isBuy && projectedValuePaise > balancePaise) {
        liveWarning = 'Order value exceeds available cash balance';
      } else if (!isBuy && parsedUnits > heldUnits) {
        liveWarning =
            'Quantity exceeds held shares (${QuantityUtils.formatQuantity(heldUnits)} available)';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} Order Ticket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Stock & Live Price Card
            Card(
              child: PriceFlashWidget(
                tick: tick,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.symbol, style: AppTextStyles.headingMedium),
                        const SizedBox(height: 4),
                        Text(stock.companyName, style: AppTextStyles.bodySmall),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          MoneyFormatter.formatPaise(ltpPaise),
                          style: AppTextStyles.monoNumbersLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.formatPaiseWithSign(changePaise)} (${MoneyFormatter.formatPercent(changePercent)})',
                          style: TextStyle(
                            color: changePaise >= 0 ? AppColors.gain : AppColors.loss,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buy / Sell Selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _onSideChanged(OrderSide.buy),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isBuy ? AppColors.gainBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isBuy ? Border.all(color: AppColors.gain) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isBuy ? AppColors.gain : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: () => _onSideChanged(OrderSide.sell),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isBuy ? AppColors.lossBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: !isBuy ? Border.all(color: AppColors.loss) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'SELL',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: !isBuy ? AppColors.loss : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quantity Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity (Shares)', style: AppTextStyles.labelLarge),
                if (isBuy)
                  Text(
                    'Available: ${MoneyFormatter.formatPaise(balancePaise)}',
                    style: AppTextStyles.bodySmall,
                  )
                else
                  Text(
                    'Held: ${QuantityUtils.formatQuantity(heldUnits)} shares',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: heldUnits > 0 ? AppColors.textPrimary : AppColors.loss,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.monoNumbersLarge,
              decoration: const InputDecoration(
                hintText: 'Enter quantity (e.g. 10 or 1.5)',
                suffixText: 'Shares',
                suffixStyle: AppTextStyles.bodyMedium,
              ),
              onChanged: (_) => setState(() => _validationError = null),
            ),

            const SizedBox(height: 10),

            // Quick Quantity Chips
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('+1'),
                  backgroundColor: AppColors.chipBackground,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () => _addQuantity(1),
                ),
                ActionChip(
                  label: const Text('+5'),
                  backgroundColor: AppColors.chipBackground,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () => _addQuantity(5),
                ),
                ActionChip(
                  label: const Text('+10'),
                  backgroundColor: AppColors.chipBackground,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () => _addQuantity(10),
                ),
                ActionChip(
                  label: const Text('+50'),
                  backgroundColor: AppColors.chipBackground,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () => _addQuantity(50),
                ),
                if (!isBuy && heldUnits > 0)
                  ActionChip(
                    label: const Text('MAX'),
                    backgroundColor: AppColors.chipBackground,
                    side: const BorderSide(color: AppColors.lossBorder),
                    onPressed: () => _setQuantity(heldUnits / 1000.0),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Summary Card
            Card(
              color: AppColors.surfaceElevated,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Execution Type', style: AppTextStyles.bodyMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('MARKET (LTP)', style: AppTextStyles.labelMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Live Market Price', style: AppTextStyles.bodyMedium),
                        Text(
                          MoneyFormatter.formatPaise(ltpPaise),
                          style: AppTextStyles.monoNumbers,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Order Value', style: AppTextStyles.labelLarge),
                        Text(
                          MoneyFormatter.formatPaise(projectedValuePaise),
                          style: AppTextStyles.monoNumbersLarge.copyWith(
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Validation / Error Messages
            if (_validationError != null || liveWarning != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lossBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lossBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.loss),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError ?? liveWarning ?? '',
                        style: const TextStyle(
                          color: AppColors.loss,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '${isBuy ? 'BUY' : 'SELL'} ${widget.symbol}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../core/widgets/price_flash_widget.dart';
import '../../../core/widgets/trading_app_bar.dart';
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
  bool _isSubmitting = false;

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
      _qtyController.text =
          qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
      _validationError = null;
    });
  }

  void _addQuantity(double add) {
    final currentUnits =
        QuantityUtils.parseQuantityToUnits(_qtyController.text) ?? 0;
    final currentQty = currentUnits / 1000.0;
    final newQty = currentQty + add;
    _setQuantity(newQty);
  }

  void _submitOrder() {
    if (_isSubmitting) return;

    final qtyText = _qtyController.text.trim();
    if (qtyText.isEmpty) {
      setState(() => _validationError = 'Enter quantity');
      return;
    }

    final quantityUnits = QuantityUtils.parseQuantityToUnits(qtyText);
    if (quantityUnits == null || quantityUnits <= 0) {
      setState(() => _validationError = 'Quantity must be greater than 0');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    final result = ref.read(orderHistoryProvider.notifier).executeOrder(
          symbol: widget.symbol,
          side: _selectedSide,
          quantityUnits: quantityUnits,
        );

    if (!result.isSuccess) {
      setState(() {
        _isSubmitting = false;
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
    final colors = context.colors;

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
    final changePaise = tick?.changePaise ??
        (stock.startingPricePaise - stock.previousClosePaise);
    final changePercent = tick?.changePercent ?? 0.0;

    // Available cash balance
    final balancePaise = ref.watch(walletBalancePaiseProvider);

    // Holdings for this symbol
    final holdings = ref.watch(holdingsProvider);
    final holding = holdings[widget.symbol];
    final heldUnits = holding?.quantityUnits ?? 0;

    // Parse entered quantity
    final rawQtyText = _qtyController.text.trim();
    final parsedUnits = QuantityUtils.parseQuantityToUnits(rawQtyText);
    final projectedValuePaise = parsedUnits != null
        ? QuantityUtils.calculateOrderValuePaise(parsedUnits, ltpPaise)
        : 0;

    final isBuy = _selectedSide == OrderSide.buy;
    final themeColor = isBuy ? colors.gain : colors.loss;

    // Real-time inline validation
    String? liveError;
    if (rawQtyText.isEmpty) {
      liveError = 'Enter quantity';
    } else if (parsedUnits == null || parsedUnits <= 0) {
      liveError = 'Quantity must be greater than 0';
    } else if (isBuy && projectedValuePaise > balancePaise) {
      liveError = 'Insufficient balance';
    } else if (!isBuy && (heldUnits == 0 || parsedUnits > heldUnits)) {
      liveError = heldUnits == 0
          ? 'Insufficient holdings (0 shares held)'
          : 'Insufficient holdings';
    }

    final isSubmitEnabled = liveError == null && !_isSubmitting;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: TradingAppBar.secondary(
        title: '${widget.symbol} Order Ticket',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Stock & Live Price Card
            Card(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colors.border),
              ),
              child: PriceFlashWidget(
                tick: tick,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.symbol,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.companyName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          MoneyFormatter.formatPaise(ltpPaise),
                          style: AppTextStyles.monoNumbersLarge.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.formatPaiseWithSign(changePaise)} (${MoneyFormatter.formatPercent(changePercent)})',
                          style: TextStyle(
                            color: changePaise >= 0 ? colors.gain : colors.loss,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'JetBrains Mono',
                            fontFeatures: const [FontFeature.tabularFigures()],
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
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
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
                          color: isBuy ? colors.gainBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isBuy ? Border.all(color: colors.gain) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isBuy ? colors.gain : colors.textSecondary,
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
                          color: !isBuy ? colors.lossBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              !isBuy ? Border.all(color: colors.loss) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'SELL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: !isBuy ? colors.loss : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quantity Input Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity (Shares)',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (isBuy)
                  Text(
                    'Available: ${MoneyFormatter.formatPaise(balancePaise)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Held: ${QuantityUtils.formatQuantity(heldUnits)} shares',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: heldUnits > 0 ? colors.textPrimary : colors.loss,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.monoNumbersLarge.copyWith(
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter quantity (e.g. 10 or 1.5)',
                suffixText: 'Shares',
                suffixStyle: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              onChanged: (_) => setState(() => _validationError = null),
            ),

            const SizedBox(height: 10),

            // Quick Quantity Chips
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label:
                      Text('+1', style: TextStyle(color: colors.textPrimary)),
                  backgroundColor: colors.chipBackground,
                  side: BorderSide(color: colors.border),
                  onPressed: () => _addQuantity(1),
                ),
                ActionChip(
                  label:
                      Text('+5', style: TextStyle(color: colors.textPrimary)),
                  backgroundColor: colors.chipBackground,
                  side: BorderSide(color: colors.border),
                  onPressed: () => _addQuantity(5),
                ),
                ActionChip(
                  label:
                      Text('+10', style: TextStyle(color: colors.textPrimary)),
                  backgroundColor: colors.chipBackground,
                  side: BorderSide(color: colors.border),
                  onPressed: () => _addQuantity(10),
                ),
                ActionChip(
                  label:
                      Text('+50', style: TextStyle(color: colors.textPrimary)),
                  backgroundColor: colors.chipBackground,
                  side: BorderSide(color: colors.border),
                  onPressed: () => _addQuantity(50),
                ),
                if (!isBuy && heldUnits > 0)
                  ActionChip(
                    label: Text('MAX', style: TextStyle(color: colors.loss)),
                    backgroundColor: colors.chipBackground,
                    side: BorderSide(color: colors.lossBorder),
                    onPressed: () => _setQuantity(heldUnits / 1000.0),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Summary Card
            Card(
              color: colors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Execution Type',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MARKET (LTP)',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Live Market Price',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          MoneyFormatter.formatPaise(ltpPaise),
                          style: AppTextStyles.monoNumbers.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: colors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Estimated Order Value',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
            if (_validationError != null || liveError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.lossBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.lossBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: colors.loss),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError ?? liveError ?? '',
                        style: TextStyle(
                          color: colors.loss,
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
              onPressed: isSubmitEnabled ? _submitOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                disabledBackgroundColor: themeColor.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '${isBuy ? 'BUY' : 'SELL'} ${widget.symbol}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
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

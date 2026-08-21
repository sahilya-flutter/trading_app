import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/utils/quantity_utils.dart';

void main() {
  group('QuantityUtils Tests', () {
    test('formatQuantity converts fixed units into readable string', () {
      expect(QuantityUtils.formatQuantity(1000), '1.000');
      expect(QuantityUtils.formatQuantity(1000, trimTrailingZeros: true), '1');
      expect(QuantityUtils.formatQuantity(10500, trimTrailingZeros: true), '10.5');
      expect(QuantityUtils.formatQuantity(10125), '10.125');
      expect(QuantityUtils.formatQuantity(250), '0.250');
    });

    test('parseQuantityToUnits converts input string to internal fixed units', () {
      expect(QuantityUtils.parseQuantityToUnits('1'), 1000);
      expect(QuantityUtils.parseQuantityToUnits('10.5'), 10500);
      expect(QuantityUtils.parseQuantityToUnits('0.25'), 250);
      expect(QuantityUtils.parseQuantityToUnits('1.125'), 1125);
      expect(QuantityUtils.parseQuantityToUnits('1.1234'), isNull); // > 3 decimals rejected
      expect(QuantityUtils.parseQuantityToUnits('-5'), isNull); // negative rejected
      expect(QuantityUtils.parseQuantityToUnits('abc'), isNull); // invalid rejected
    });

    test('calculateOrderValuePaise computes order value correctly in integer paise', () {
      // 10 shares (10,000 units) at ₹1,420.00 (142,000 paise) = ₹14,200.00 (1,420,000 paise)
      expect(QuantityUtils.calculateOrderValuePaise(10000, 142000), 1420000);

      // 0.5 shares (500 units) at ₹3,980.00 (398,000 paise) = ₹1,990.00 (199,000 paise)
      expect(QuantityUtils.calculateOrderValuePaise(500, 398000), 199000);
    });

    test('calculateNewAveragePricePaise computes weighted average correctly', () {
      // Existing 10 shares @ ₹100 (10,000 paise)
      // Buy 10 shares @ ₹200 (20,000 paise)
      // New average = (10*10000 + 10*20000) / 20 = 15,000 paise (₹150)
      final avg = QuantityUtils.calculateNewAveragePricePaise(
        existingUnits: 10000,
        existingAvgPricePaise: 10000,
        boughtUnits: 10000,
        executionPricePaise: 20000,
      );
      expect(avg, 15000);
    });
  });
}

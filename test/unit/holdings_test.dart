import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/features/holdings/domain/holding.dart';

void main() {
  group('Holding Model Tests', () {
    test('Calculates invested value, current value, and P&L accurately in paise', () {
      // Holding 10 shares (10,000 units) at avg buy ₹1,400.00 (140,000 paise)
      const holding = Holding(
        symbol: 'RELIANCE',
        quantityUnits: 10000,
        averagePricePaise: 140000,
      );

      // Invested Value: 10 * 1400 = ₹14,000.00 (1,400,000 paise)
      expect(holding.investedValuePaise, 1400000);

      // If current LTP is ₹1,450.00 (145,000 paise)
      // Current Value: 10 * 1450 = ₹14,500.00 (1,450,000 paise)
      expect(holding.currentValuePaise(145000), 1450000);

      // P&L: 1,450,000 - 1,400,000 = +50,000 paise (+₹500.00)
      expect(holding.pnlPaise(145000), 50000);

      // P&L %: (50000 / 1400000) * 100 = 3.5714...%
      expect(holding.pnlPercent(145000), closeTo(3.57, 0.01));
    });

    test('Calculates loss correctly when LTP is lower than average price', () {
      const holding = Holding(
        symbol: 'TCS',
        quantityUnits: 5000, // 5 shares
        averagePricePaise: 400000, // ₹4000
      );

      // Invested = 5 * 4000 = ₹20,000 (2,000,000 paise)
      expect(holding.investedValuePaise, 2000000);

      // Current LTP = ₹3,900 (390,000 paise)
      // Current = 5 * 3900 = ₹19,500 (1,950,000 paise)
      expect(holding.currentValuePaise(390000), 1950000);

      // P&L = -50,000 paise (-₹500)
      expect(holding.pnlPaise(390000), -50000);

      // P&L % = -2.5%
      expect(holding.pnlPercent(390000), -2.5);
    });
  });
}

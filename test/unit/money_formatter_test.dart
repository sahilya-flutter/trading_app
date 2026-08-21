import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter Tests', () {
    test('formatPaise formats paise correctly into Indian Rupees', () {
      expect(MoneyFormatter.formatPaise(142000), '₹1,420.00');
      expect(MoneyFormatter.formatPaise(15235), '₹152.35');
      expect(MoneyFormatter.formatPaise(0), '₹0.00');
      expect(MoneyFormatter.formatPaise(-5000), '-₹50.00');
    });

    test('formatPaiseWithSign formats with explicit +/- sign', () {
      expect(MoneyFormatter.formatPaiseWithSign(215), '+₹2.15');
      expect(MoneyFormatter.formatPaiseWithSign(-420), '-₹4.20');
      expect(MoneyFormatter.formatPaiseWithSign(0), '₹0.00');
    });

    test('formatPercent formats double percentage correctly', () {
      expect(MoneyFormatter.formatPercent(0.152), '+0.15%');
      expect(MoneyFormatter.formatPercent(-0.11), '-0.11%');
      expect(MoneyFormatter.formatPercent(0.0), '0.00%');
    });

    test('parseRupeesToPaise parses strings safely without floating point drift', () {
      expect(MoneyFormatter.parseRupeesToPaise('152.35'), 15235);
      expect(MoneyFormatter.parseRupeesToPaise('1420'), 142000);
      expect(MoneyFormatter.parseRupeesToPaise('0.5'), 50);
      expect(MoneyFormatter.parseRupeesToPaise('0.05'), 5);
      expect(MoneyFormatter.parseRupeesToPaise('₹1,420.00'), 142000);
      expect(MoneyFormatter.parseRupeesToPaise('invalid'), isNull);
      expect(MoneyFormatter.parseRupeesToPaise('10.123'), isNull); // > 2 decimal places
    });
  });
}

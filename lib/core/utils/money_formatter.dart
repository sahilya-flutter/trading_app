import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _inCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inNumberFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  /// Formats paise integer as Indian Rupees: e.g. 142000 -> "₹1,420.00"
  static String formatPaise(
    int paise, {
    bool showSymbol = true,
    bool showDecimals = true,
  }) {
    final isNegative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise / 100.0;

    String formatted = showSymbol
        ? _inCurrencyFormat.format(rupees)
        : _inNumberFormat.format(rupees).trim();

    if (!showDecimals && formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }

    return isNegative ? '-$formatted' : formatted;
  }

  /// Formats paise with explicit sign: e.g. 215 -> "+₹2.15", -420 -> "-₹4.20", 0 -> "₹0.00"
  static String formatPaiseWithSign(int paise, {bool showSymbol = true}) {
    if (paise > 0) {
      return '+${formatPaise(paise, showSymbol: showSymbol)}';
    } else if (paise < 0) {
      return '-${formatPaise(paise.abs(), showSymbol: showSymbol)}';
    } else {
      return formatPaise(0, showSymbol: showSymbol);
    }
  }

  /// Formats percentage: e.g. 0.152 -> "+0.15%", -0.11 -> "-0.11%"
  static String formatPercent(double percent, {bool showSign = true}) {
    final formatted = percent.abs().toStringAsFixed(2);
    if (percent > 0.0001) {
      return showSign ? '+$formatted%' : '$formatted%';
    } else if (percent < -0.0001) {
      return '-$formatted%';
    } else {
      return '0.00%';
    }
  }

  /// Safely parses user input string into integer paise without floating-point drift.
  /// Example: "152.35" -> 15235, "100" -> 10000, "0.5" -> 50, "0.05" -> 5
  static int? parseRupeesToPaise(String input) {
    final clean = input.trim().replaceAll(',', '').replaceAll('₹', '');
    if (clean.isEmpty) return null;

    final parts = clean.split('.');
    if (parts.length > 2) return null;

    final intPart = int.tryParse(parts[0]);
    if (intPart == null) return null;

    int decimalPaise = 0;
    if (parts.length == 2) {
      final decStr = parts[1];
      if (decStr.length > 2) {
        return null; // Exceeds paise precision
      }
      if (decStr.length == 1) {
        decimalPaise = (int.tryParse(decStr) ?? 0) * 10;
      } else if (decStr.length == 2) {
        decimalPaise = int.tryParse(decStr) ?? 0;
      }
    }

    if (intPart < 0) {
      return (intPart * 100) - decimalPaise;
    }
    return (intPart * 100) + decimalPaise;
  }
}

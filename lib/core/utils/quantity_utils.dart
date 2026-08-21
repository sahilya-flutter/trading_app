import '../constants/app_constants.dart';

class QuantityUtils {
  QuantityUtils._();

  /// Converts internal minor units (e.g. 1250) into display string (e.g. "1.250" or "1.25")
  static String formatQuantity(int quantityUnits, {bool trimTrailingZeros = false}) {
    final integerPart = quantityUnits ~/ AppConstants.quantityMultiplier;
    final fractionalPart = (quantityUnits % AppConstants.quantityMultiplier).abs();

    final formattedFrac = fractionalPart.toString().padLeft(AppConstants.maxQuantityDecimalPlaces, '0');
    final raw = '$integerPart.$formattedFrac';

    if (trimTrailingZeros) {
      if (fractionalPart == 0) return integerPart.toString();
      var trimmed = raw;
      while (trimmed.endsWith('0')) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
      if (trimmed.endsWith('.')) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
      return trimmed;
    }

    return raw;
  }

  /// Parses user quantity input into internal fixed units (multiplier 1000).
  /// Rejects strings with more than 3 decimal places or negative/invalid values.
  static int? parseQuantityToUnits(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return null;

    final parts = clean.split('.');
    if (parts.length > 2) return null;

    final intPart = int.tryParse(parts[0]);
    if (intPart == null || intPart < 0) return null;

    int fracUnits = 0;
    if (parts.length == 2) {
      final fracStr = parts[1];
      if (fracStr.length > AppConstants.maxQuantityDecimalPlaces) {
        return null; // Exceeds supported precision (max 3 decimals)
      }
      final padded = fracStr.padRight(AppConstants.maxQuantityDecimalPlaces, '0');
      fracUnits = int.tryParse(padded) ?? 0;
    }

    final totalUnits = (intPart * AppConstants.quantityMultiplier) + fracUnits;
    return totalUnits;
  }

  /// Calculates total order value in integer paise:
  /// (quantityUnits * pricePaise) / quantityMultiplier
  static int calculateOrderValuePaise(int quantityUnits, int pricePaise) {
    if (quantityUnits <= 0 || pricePaise <= 0) return 0;
    return (quantityUnits * pricePaise) ~/ AppConstants.quantityMultiplier;
  }

  /// Calculates new weighted average price when buying additional shares:
  /// ((existingUnits * existingAvgPaise) + (boughtUnits * executionPricePaise)) / newTotalUnits
  static int calculateNewAveragePricePaise({
    required int existingUnits,
    required int existingAvgPricePaise,
    required int boughtUnits,
    required int executionPricePaise,
  }) {
    final totalUnits = existingUnits + boughtUnits;
    if (totalUnits <= 0) return 0;

    final existingTotalPaise = (existingUnits * existingAvgPricePaise);
    final newBoughtTotalPaise = (boughtUnits * executionPricePaise);

    return (existingTotalPaise + newBoughtTotalPaise) ~/ totalUnits;
  }
}

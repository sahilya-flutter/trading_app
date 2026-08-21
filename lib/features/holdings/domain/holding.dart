import '../../../core/constants/app_constants.dart';

class Holding {
  final String symbol;
  final int quantityUnits; // 1000 units = 1.000 share
  final int averagePricePaise;

  const Holding({
    required this.symbol,
    required this.quantityUnits,
    required this.averagePricePaise,
  });

  /// Total rupee amount invested in this holding (paise)
  int get investedValuePaise {
    return (quantityUnits * averagePricePaise) ~/ AppConstants.quantityMultiplier;
  }

  /// Current market value based on live LTP (paise)
  int currentValuePaise(int currentLtpPaise) {
    return (quantityUnits * currentLtpPaise) ~/ AppConstants.quantityMultiplier;
  }

  /// Absolute P&L in paise
  int pnlPaise(int currentLtpPaise) {
    return currentValuePaise(currentLtpPaise) - investedValuePaise;
  }

  /// P&L Percentage
  double pnlPercent(int currentLtpPaise) {
    final invested = investedValuePaise;
    if (invested <= 0) return 0.0;
    return (pnlPaise(currentLtpPaise) / invested) * 100.0;
  }

  Holding copyWith({
    String? symbol,
    int? quantityUnits,
    int? averagePricePaise,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantityUnits: quantityUnits ?? this.quantityUnits,
      averagePricePaise: averagePricePaise ?? this.averagePricePaise,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantityUnits': quantityUnits,
        'averagePricePaise': averagePricePaise,
      };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
        symbol: json['symbol'] as String,
        quantityUnits: (json['quantityUnits'] as num).toInt(),
        averagePricePaise: (json['averagePricePaise'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Holding &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}

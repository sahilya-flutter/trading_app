class Stock {
  final String symbol;
  final String companyName;
  final int startingPricePaise;
  final int previousClosePaise;

  const Stock({
    required this.symbol,
    required this.companyName,
    required this.startingPricePaise,
    required this.previousClosePaise,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'companyName': companyName,
        'startingPricePaise': startingPricePaise,
        'previousClosePaise': previousClosePaise,
      };

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        symbol: json['symbol'] as String,
        companyName: json['companyName'] as String? ?? '',
        startingPricePaise: (json['startingPricePaise'] as num).toInt(),
        previousClosePaise: (json['previousClosePaise'] as num?)?.toInt() ??
            (json['startingPricePaise'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stock &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}

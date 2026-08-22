enum TickDirection {
  up,
  down,
  unchanged;

  String toJson() => name;
  static TickDirection fromJson(String name) {
    switch (name) {
      case 'up':
        return TickDirection.up;
      case 'down':
        return TickDirection.down;
      default:
        return TickDirection.unchanged;
    }
  }
}

class PriceTick {
  final String symbol;
  final int ltpPaise;
  final int previousLtpPaise;
  final int deltaPaise;
  final int previousClosePaise;
  final int changePaise;
  final double changePercent;
  final DateTime timestamp;
  final TickDirection direction;

  const PriceTick({
    required this.symbol,
    required this.ltpPaise,
    required this.previousLtpPaise,
    required this.deltaPaise,
    required this.previousClosePaise,
    required this.changePaise,
    required this.changePercent,
    required this.timestamp,
    required this.direction,
  });

  factory PriceTick.initial({
    required String symbol,
    required int startingPricePaise,
    required int previousClosePaise,
  }) {
    final change = startingPricePaise - previousClosePaise;
    final changePct = previousClosePaise > 0
        ? (change / previousClosePaise) * 100
        : 0.0;

    return PriceTick(
      symbol: symbol,
      ltpPaise: startingPricePaise,
      previousLtpPaise: startingPricePaise,
      deltaPaise: 0,
      previousClosePaise: previousClosePaise,
      changePaise: change,
      changePercent: changePct,
      timestamp: DateTime.now(),
      direction: TickDirection.unchanged,
    );
  }

  factory PriceTick.fromUpdate({
    required String symbol,
    required int newLtpPaise,
    required int previousLtpPaise,
    required int previousClosePaise,
  }) {
    final delta = newLtpPaise - previousLtpPaise;
    final change = newLtpPaise - previousClosePaise;
    final changePct = previousClosePaise > 0
        ? (change / previousClosePaise) * 100
        : 0.0;

    final direction = delta > 0
        ? TickDirection.up
        : delta < 0
            ? TickDirection.down
            : TickDirection.unchanged;

    return PriceTick(
      symbol: symbol,
      ltpPaise: newLtpPaise,
      previousLtpPaise: previousLtpPaise,
      deltaPaise: delta,
      previousClosePaise: previousClosePaise,
      changePaise: change,
      changePercent: changePct,
      timestamp: DateTime.now(),
      direction: direction,
    );
  }

  bool get isPositive => changePaise >= 0;
  bool get isNegative => changePaise < 0;
  bool get isUp => direction == TickDirection.up;
  bool get isDown => direction == TickDirection.down;
  bool get isUnchanged => direction == TickDirection.unchanged;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'ltpPaise': ltpPaise,
        'previousLtpPaise': previousLtpPaise,
        'deltaPaise': deltaPaise,
        'previousClosePaise': previousClosePaise,
        'changePaise': changePaise,
        'changePercent': changePercent,
        'timestamp': timestamp.toIso8601String(),
        'direction': direction.toJson(),
      };

  factory PriceTick.fromJson(Map<String, dynamic> json) => PriceTick(
        symbol: json['symbol'] as String,
        ltpPaise: (json['ltpPaise'] as num).toInt(),
        previousLtpPaise: (json['previousLtpPaise'] as num).toInt(),
        deltaPaise: (json['deltaPaise'] as num).toInt(),
        previousClosePaise: (json['previousClosePaise'] as num).toInt(),
        changePaise: (json['changePaise'] as num).toInt(),
        changePercent: (json['changePercent'] as num).toDouble(),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        direction: TickDirection.fromJson(json['direction'] as String? ?? ''),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceTick &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          ltpPaise == other.ltpPaise &&
          previousLtpPaise == other.previousLtpPaise &&
          deltaPaise == other.deltaPaise &&
          previousClosePaise == other.previousClosePaise &&
          changePaise == other.changePaise &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(
        symbol,
        ltpPaise,
        previousLtpPaise,
        deltaPaise,
        previousClosePaise,
        changePaise,
        direction,
      );

  @override
  String toString() =>
      'PriceTick($symbol: ${ltpPaise}p, Δ:${deltaPaise}p, $direction)';
}

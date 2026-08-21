enum TickDirection {
  up,
  down,
  unchanged,
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

  @override
  String toString() =>
      'PriceTick($symbol: ${ltpPaise}p, Δ:${deltaPaise}p, $direction)';
}

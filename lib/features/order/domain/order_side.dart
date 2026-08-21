enum OrderSide {
  buy,
  sell,
}

extension OrderSideExtension on OrderSide {
  String get displayName {
    switch (this) {
      case OrderSide.buy:
        return 'BUY';
      case OrderSide.sell:
        return 'SELL';
    }
  }

  bool get isBuy => this == OrderSide.buy;
  bool get isSell => this == OrderSide.sell;
}

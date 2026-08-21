import 'order_side.dart';

enum OrderStatus {
  executed,
  failed,
}

class OrderModel {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantityUnits;
  final int executionPricePaise;
  final int orderValuePaise;
  final DateTime timestamp;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantityUnits,
    required this.executionPricePaise,
    required this.orderValuePaise,
    required this.timestamp,
    this.status = OrderStatus.executed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantityUnits': quantityUnits,
        'executionPricePaise': executionPricePaise,
        'orderValuePaise': orderValuePaise,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        side: OrderSide.values.byName(json['side'] as String),
        quantityUnits: (json['quantityUnits'] as num).toInt(),
        executionPricePaise: (json['executionPricePaise'] as num).toInt(),
        orderValuePaise: (json['orderValuePaise'] as num).toInt(),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        status: json['status'] != null
            ? OrderStatus.values.byName(json['status'] as String)
            : OrderStatus.executed,
      );
}

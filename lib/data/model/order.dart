import 'package:pizza_management/data/model/order_details.dart';

class Order {
  final int id;
  final double totalPrice;
  final String status;
  final DateTime paidAt;
  final List<OrderDetails> orderDetails;

  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.paidAt,
    required this.orderDetails
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
        other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'] ?? "",
      paidAt: DateTime.parse(json['paidAt']),
      orderDetails: json['detailsResponses'] != null
          ? (json['detailsResponses'] as List)
          .map((i) => OrderDetails.fromJson(i))
          .toList()
          : [],
    );
  }

  @override
  String toString() => 'Order(Id: $id, OrderDetails : $orderDetails)';
}
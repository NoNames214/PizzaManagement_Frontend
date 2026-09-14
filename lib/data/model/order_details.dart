import 'package:pizza_management/data/model/pizza.dart';

class OrderDetails {
  final int id;
  final int quantity;
  final double priceAtPurchase;
  final Pizza ?pizza;

  OrderDetails({
    required this.id,
    required this.quantity,
    required this.priceAtPurchase,
    required this.pizza,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: json['priceAtPurchase']?.toDouble() ?? 0.0,
      pizza: json['pizza'] != null ? Pizza.fromJson(json['pizza']) : null,
    );
  }

  @override
  String toString() {
    return 'OrderDetails(Id : $id, quantity: $quantity, price: $priceAtPurchase, pizza: $pizza)';
  }
}
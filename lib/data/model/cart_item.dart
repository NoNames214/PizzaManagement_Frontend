import 'package:pizza_management/data/model/pizza.dart';

class CartItem {
  final int id;
  final int userId;
  final int pizzaId;
  late final int quantity;
  final Pizza ? pizza;

  CartItem({
    required this.id,
    required this.userId,
    required this.pizzaId,
    required this.quantity,
    this.pizza,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
        id: json['id'],
        userId: json['userId'],
        pizzaId: json['pizzaId'],
        quantity: json['quantity'],
        pizza: json['pizza'] != null
            ? Pizza.fromJson(json['pizza'])
            : null
    );
  }

  @override
  String toString () => 'CartItem(id : $id, userId : $userId, pizzaId : $pizzaId)';
}

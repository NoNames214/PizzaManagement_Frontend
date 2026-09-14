class OrderDetailsRequest {
  final int pizzaId;
  final int quantity;

  OrderDetailsRequest({
    required this.pizzaId,
    required this.quantity
  });

  Map<String, dynamic> toJson() {
    return {
      "pizzaId": pizzaId,
      "quantity": quantity,
    };
  }

  @override
  String toString() => 'OrderDetailsRequest(id : $pizzaId, quantity : $quantity)';
}
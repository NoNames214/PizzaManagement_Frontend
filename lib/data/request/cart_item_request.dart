class CartItemRequest {
  final int pizzaId;
  final int quantity;

  CartItemRequest({
    required this.pizzaId,
    required this.quantity
  });

  Map<String, dynamic> toJson() {
    return {
      "pizzaId": pizzaId,
      "quantity": quantity,
    };
  }
}
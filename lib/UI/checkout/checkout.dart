import 'package:flutter/material.dart';
import '../../data/ai_recommend/interaction_type.dart';
import '../../data/api/api_constant.dart';
import '../../data/model/cart_item.dart';
import '../../data/repository/ai_repository.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/cart_repository.dart';
import '../../data/repository/order_repository.dart';
import '../../data/request/order_request.dart';
import '../../data/request/order_details_request.dart';

class CheckOutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckOutScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Map<int, String> selectedSizes = {};
  final OrderRepository _orderRepository = OrderRepository();
  final AuthRepository _authRepository = AuthRepository();
  final AIRepository _aiRepository = AIRepository();
  final CartRepository _cartRepository = CartRepository();

  @override
  void initState() {
    super.initState();
    for (final item in widget.cartItems) {
      selectedSizes[item.id] = "M";
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = totalPrice();
    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9),
      appBar: AppBar(
        title: const Text("Payment"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Column(
                    children: widget.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                ApiConstant.pizzaImage(item.pizza!.image),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.pizza!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Size",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      _buildSizeButton("S", item),
                                      _buildSizeButton("M", item),
                                      _buildSizeButton("L", item),
                                    ],
                                  ),
                                  Text(
                                    "Quantity: ${item.quantity}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Total', overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  _buildMethod(Icons.credit_card, "Credit Card"),
                  const Divider(),
                  _buildMethod(Icons.account_balance_wallet, "E-Wallet"),
                  const Divider(),
                  _buildMethod(Icons.money, "Cash"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final token = await _authRepository.getToken();
                  final detailsRequest = widget.cartItems.map((item) {
                    return OrderDetailsRequest(
                      pizzaId: item.pizzaId,
                      quantity: item.quantity,
                    );
                  }).toList();
                  final orderRequest = OrderRequest(detailsRequest: detailsRequest);
                  final order = await _orderRepository.createOrder(orderRequest);
                  final String eventType = InteractionType.purchase;
                  if (token != null) {
                    await _orderRepository.processPayment(order.id, token);

                    for (final item in widget.cartItems) {
                      await _cartRepository.deleteCartItem(item.id);
                    }

                    for (final item in widget.cartItems) {
                      await _aiRepository.trackUserAction(item.pizzaId, eventType, token);
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token is null')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(String size, CartItem item) {
    final isSelected = selectedSizes[item.id] == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSizes[item.id] = size;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE57351) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  double totalPrice() {
    double total = 0;
    for (final item in widget.cartItems) {
      total += item.pizza!.price * item.quantity;
    }
    return total;
  }

  Widget _buildMethod(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

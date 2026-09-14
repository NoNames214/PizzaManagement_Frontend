import 'package:flutter/material.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import 'package:pizza_management/data/repository/order_repository.dart';
import 'package:pizza_management/data/request/order_request.dart';
import 'package:pizza_management/data/request/order_details_request.dart';
import '../../data/ai_recommend/interaction_type.dart';
import '../../data/repository/auth_repository.dart';

class PaymentScreen extends StatelessWidget {
  final Pizza pizza;
  final int quantity;
  final String size;
  final Future<void> Function()? refreshRecommend;

  const PaymentScreen({
    super.key,
    required this.pizza,
    required this.quantity,
    required this.size,
    this.refreshRecommend,
  });

  @override
  Widget build(BuildContext context) {
    double total = pizza.price * quantity;
    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9),
      appBar: AppBar(
        title: const Text("Payment"),
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
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          ApiConstant.pizzaImage(pizza.image),
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
                              pizza.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Size: $size",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Quantity: $quantity",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  final orderRepository = OrderRepository();
                  final authRepository = AuthRepository();
                  final token = await authRepository.getToken();
                  final List<OrderDetailsRequest> detailsRequest = [
                    OrderDetailsRequest(
                        pizzaId: pizza.id,
                        quantity: quantity
                    ),
                  ];
                  final orderRequest = OrderRequest(detailsRequest: detailsRequest);
                  final order = await orderRepository.createOrder(orderRequest);
                  final String eventType = InteractionType.purchase;

                  if (token != null) {
                    await orderRepository.processPayment(order.id, token);
                    await AIRepository().trackUserAction(pizza.id, eventType, token);
                    await refreshRecommend?.call();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                  else {
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

  Widget _buildMethod(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
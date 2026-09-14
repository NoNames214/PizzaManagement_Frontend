import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/review/review.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import '../../data/model/order.dart';
import '../../data/repository/order_repository.dart';

class HistoryOrder extends StatefulWidget {
  const HistoryOrder({super.key});

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Order> order = [];
  bool isLoading = true;
  final logger = Logger();

  Future<void> loadData() async {
    try {
      final data = await _orderRepository.getOrders();
      if (!mounted) return;
      setState(() {
        order.addAll(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: const CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: order.length,
        itemBuilder: (context, index) {
          final item = order[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (var detail in item.orderDetails)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  ApiConstant.pizzaImage(detail.pizza!.image),
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ${item.id}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      "Category: ${detail.pizza!.categoryName}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      detail.pizza!.name,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      "${item.paidAt.day.toString().padLeft(2, '0')}"
                                          "/${item.paidAt.month.toString().padLeft(2, '0')}"
                                          "/${item.paidAt.year}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    Text(
                                      "${item.totalPrice.toStringAsFixed(2)}\$",
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context)
                                      => ReviewScreen(
                                        orderDetails: detail,
                                      ),
                                  )
                                );
                              },
                              icon: Icon(Icons.rate_review, size: 18),
                              label: Text('Review'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                    ),

                  const Divider(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
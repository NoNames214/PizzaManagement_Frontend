import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/order_repository.dart';
import 'package:pizza_management/data/request/order_request.dart';
import 'package:pizza_management/data/request/order_details_request.dart';
import 'package:pizza_management/data/service/vn_pay_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/vn_pay_repository.dart';

class PaymentScreen extends StatefulWidget {
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'pizza_management' && uri.host == 'payment-callback') {
        final status = uri.queryParameters['status'];
        final orderId = uri.queryParameters['orderId'];

        if (!mounted) return;
        if (status == 'success') {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Success. Order ID: $orderId')),
          );

          if (widget.refreshRecommend != null) {
            widget.refreshRecommend!();
          }
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Failed')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.pizza.price * widget.quantity;

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
                          ApiConstant.pizzaImage(widget.pizza.image),
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
                              widget.pizza.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Size: ${widget.size}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Quantity: ${widget.quantity}",
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
                  try {
                    final authRepository = AuthRepository();
                    final token = await authRepository.getToken();
                    if (token == null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token is null')),
                      );
                      return;
                    }
                    final orderRepository = OrderRepository();
                    final detailsRequest = <OrderDetailsRequest>[
                      OrderDetailsRequest(
                        pizzaId: widget.pizza.id,
                        quantity: widget.quantity,
                      ),
                    ];
                    final orderRequest = OrderRequest(detailsRequest: detailsRequest);
                    final order = await orderRepository.createOrder(orderRequest);

                    final vnPayRepository = VnPayRepository(VnPayService());
                    final paymentUrl = await vnPayRepository.createPaymentUrl(order.id);
                    final uri = Uri.parse(paymentUrl);
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.inAppBrowserView,
                    );
                    if (!launched) {
                      throw Exception('Could not launch VNPay');
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment error: $e')),
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
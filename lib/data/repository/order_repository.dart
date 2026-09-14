import 'package:logger/logger.dart';
import '../model/order.dart';
import '../request/order_request.dart';
import '../service/order_service.dart';

class OrderRepository {
  final OrderService _orderService = OrderService();
  final logger = Logger();

  Future<List<Order>> getOrders() async {
    try {
      return await _orderService.getOrder();
    }
    catch (e) {
      logger.e("Get Order Failed: $e");
      return [];
    }
  }

  Future<Order> createOrder(OrderRequest orderRequest) async {
    try {
      return await _orderService.createOrder(orderRequest);
    }
    catch (e) {
      logger.e("Create Order Failed: $e");
      rethrow;
    }
  }

  Future<bool> processPayment (int orderId, String token) async {
    try {
      return await _orderService.processPayment(orderId, token);
    }
    catch (e) {
      logger.e("Process Payment Failed: $e");
      return false;
    }
  }
}
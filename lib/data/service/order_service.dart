import 'package:dio/dio.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';
import '../model/order.dart';
import '../request/order_request.dart';

class OrderService {
  static final OrderService _orderService = OrderService._internal();
  factory OrderService() => _orderService;
  OrderService._internal();

  final _dio = DioClient().dio;

  Future<List<Order>> getOrder() async {
    try {
      final response = await _dio.get('/order');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Order> createOrder(OrderRequest orderRequest) async {
    try {
      final response = await _dio.post(
        '/order',
        data:  orderRequest.toJson()
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }
  Future<bool> processPayment (int orderId, String token) async {
    try {
      final response = await _dio.post(
          '/order/$orderId/payment',
          options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              }
          )
      );
      if (response.statusCode == 204) {
        return true;
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
      }
  }
}

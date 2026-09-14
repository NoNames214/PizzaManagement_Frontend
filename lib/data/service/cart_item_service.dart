import 'package:dio/dio.dart';
import 'package:pizza_management/data/model/cart_item.dart';
import 'package:pizza_management/data/request/cart_item_request.dart';
import '../interceptor/dio_client.dart';

class CartItemService {
  static final CartItemService _cartItemService = CartItemService._internal();
  factory CartItemService() => _cartItemService;
  CartItemService._internal();

  final _dio = DioClient().dio;

  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await _dio.get('Cart');
      print(response.statusCode);
      print(response.data);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => CartItem.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> addToCart(CartItemRequest request) async {
    try {
      final response = await _dio.post(
          '/Cart',
          data: request.toJson()
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<bool> deleteCartItem (int id) async {
    try {
      final response = await _dio.delete('/Cart/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
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

  Future<bool> updateQuantity (CartItemRequest request, int id) async {
    try {
      final response = await _dio.patch(
          '/Cart/$id',
          data: request.toJson()
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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
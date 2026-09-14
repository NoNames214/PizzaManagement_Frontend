import 'package:logger/logger.dart';
import '../model/cart_item.dart';
import '../request/cart_item_request.dart';
import '../service/cart_item_service.dart';

class CartRepository {
  final logger = Logger();
  final CartItemService _cartItemService = CartItemService();

  Future<List<CartItem>> getCartItems() async {
    try {
      return await _cartItemService.getCartItems();
    }
    catch(e) {
      logger.e('Get Cart Items Failed: $e');
      return [];
    }
  }

  Future<bool> addToCart(CartItemRequest request) async {
    try {
      return await _cartItemService.addToCart(request);
    }
    catch(e) {
      logger.e('Add To Cart Failed: $e');
      return false;
    }
  }

  Future<bool> deleteCartItem(int id) async {
    try {
      return await _cartItemService.deleteCartItem(id);
    }
    catch(e) {
      logger.e('Delete Cart Item Failed: $e');
      return false;
    }
  }
  Future<bool> updateQuantity(CartItemRequest request, int id) async {
    try {
      return await _cartItemService.updateQuantity(request, id);
    }
    catch(e) {
      logger.e('Update Cart Item Failed: $e');
      return false;
    }
  }
}
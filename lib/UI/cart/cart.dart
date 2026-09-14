import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/checkout/checkout.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/model/cart_item.dart';
import 'package:pizza_management/data/repository/cart_repository.dart';
import 'package:pizza_management/data/request/cart_item_request.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool isLoading = true;
  final log = Logger();
  final _cartRepository = CartRepository();

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final data = await _cartRepository.getCartItems();
      if (!mounted) return;
      setState(() {
        cartItems = data;
        isLoading = false;
      });
    } catch (e) {
      log.e('Load Cart Failed: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showDeleteDialog(CartItem item) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Item',
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final success = await _cartRepository.deleteCartItem(item.id);
        if (success) {
          await loadCart();
        }
      } catch (e) {
        log.e('Delete Cart Item Failed: $e');
      }
    }
  }

  double totalPrice() {
    double total = 0;
    for (final item in cartItems) {
      total += item.pizza!.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 90, color: Colors.grey),
            SizedBox(height: 15),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 15,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.red,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "My Cart",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: RefreshIndicator(
            onRefresh: loadCart,
            child: ListView.builder(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _buildCartItemCard(cartItems[index]),
            ),
          ),
        ),

        Expanded(
          flex: 35,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Items:', style: TextStyle(fontSize: 16)),
                    Text(
                      '${cartItems.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(
                      '\$${totalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text(
                      "Checkout",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _navigateToCheckout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadCart,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _buildCartItemCard(cartItems[index]),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 80, top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.black87)),
                    Text(
                      '\$${totalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _navigateToCheckout,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiConstant.pizzaImage(item.pizza!.image),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_,_, _) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.local_pizza, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.pizza!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${item.pizza!.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subtotal: \$${(item.pizza!.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () async {
                            if (item.quantity <= 1) return;
                            final success = await _cartRepository.updateQuantity(
                              CartItemRequest(
                                pizzaId: item.pizzaId,
                                quantity: item.quantity - 1,
                              ),
                              item.id,
                            );
                            if (success) {
                              loadCart();
                            }
                          },
                        ),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () async {
                            final success = await _cartRepository.updateQuantity(
                              CartItemRequest(
                                pizzaId: item.pizzaId,
                                quantity: item.quantity + 1,
                              ),
                              item.id,
                            );
                            if (success) {
                              loadCart();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(item),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCheckout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckOutScreen(
          cartItems: cartItems,
        ),
      ),
    );
    if (result == true) {
      loadCart();
    }
  }
}
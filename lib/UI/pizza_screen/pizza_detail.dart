import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pizza_management/UI/payment/payment.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import 'package:pizza_management/data/repository/auth_repository.dart';
import 'package:pizza_management/data/repository/cart_repository.dart';
import 'package:pizza_management/data/request/cart_item_request.dart';
import '../../data/ai_recommend/interaction_type.dart';
import '../../data/model/pizza.dart';
import '../../data/service/ai_recommend_service.dart';
import '../../data/service/auth_service.dart';

class PizzaDetailScreen extends StatefulWidget {
  final Pizza pizza;
  final Future<void> Function()? refreshRecommend;

  const PizzaDetailScreen({
    super.key,
    required this.pizza,
    this.refreshRecommend,
  });

  @override
  State<PizzaDetailScreen> createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends State<PizzaDetailScreen> {
  String selectedSize = "M";
  int quantity = 1;
  bool isFavorite = false;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _authRepository.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final randomRating = (3.5 + Random().nextDouble() * 1.5).toStringAsFixed(1);
    final pizza = widget.pizza;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isDesktop
          ? _buildDesktopLayout(context, pizza, randomRating)
          : _buildMobileLayout(context, pizza, randomRating),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, Pizza pizza, String randomRating) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final authService = AuthService();
              final result = await Future.wait([authService.getToken()]);
              final token = result[0];
              if (token != null) {
                await AIRecommend().trackUserAction(
                    pizza.id, InteractionType.dismiss, token);
                await widget.refreshRecommend?.call();
                if (!context.mounted) return;
                Navigator.pop(context);
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token is null')),
                );
              }
            },
            icon: const Icon(Icons.close, color: Colors.red, size: 28),
          ),
          IconButton(
            onPressed: () => setState(() => isFavorite = !isFavorite),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: Container(
          width: 1100,
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Hero(
                    tag: pizza.id,
                    child: Image.network(
                      ApiConstant.pizzaImage(pizza.image),
                      fit: BoxFit.cover,
                      height: 450,
                      errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.fastfood, size: 80)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: _buildDetailContent(pizza, randomRating),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, Pizza pizza, String randomRating) {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Hero(
            tag: pizza.id,
            child: Image.network(
              ApiConstant.pizzaImage(pizza.image),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.fastfood, size: 80));
              },
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => setState(() => isFavorite = !isFavorite),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 80,
          child: SafeArea(
            child: GestureDetector(
              onTap: () async {
                final authService = AuthService();
                final result = await Future.wait([authService.getToken()]);
                final token = result[0];
                if (token != null) {
                  await AIRecommend().trackUserAction(
                      pizza.id, InteractionType.dismiss, token);
                  await widget.refreshRecommend?.call();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token is null')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 30, color: Colors.red),
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.62,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildDetailContent(pizza, randomRating),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailContent(Pizza pizza, String randomRating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                pizza.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "\$${pizza.price}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE57351),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildInfoChip(Icons.star, randomRating, Colors.orange),
            const SizedBox(width: 8),
            _buildInfoChip(
                Icons.straighten,
                "${pizza.mainIngredient?.size.toStringAsFixed(0)} inch",
                Colors.blue),
            const SizedBox(width: 8),
            if ((pizza.mainIngredient?.priceRange ?? 0) >= 0)
              _buildInfoChip(
                  Icons.local_fire_department_rounded,
                  "${pizza.mainIngredient?.spicinessLevel.toStringAsFixed(0)}",
                  Colors.red),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          "Toppings",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: pizza.toppingsName.map((toppingName) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                toppingName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),
        const Text(
          "Size",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildSizeButton("S"),
            _buildSizeButton("M"),
            _buildSizeButton("L"),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "Quantity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildQuantityButton(Icons.remove, () {
              if (quantity > 1) {
                setState(() => quantity--);
              }
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildQuantityButton(Icons.add, () {
              setState(() => quantity++);
            }),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    final token = await _authRepository.getToken();
                    final String eventType = InteractionType.addToCart;
                    if (token != null) {
                      await AIRepository()
                          .trackUserAction(pizza.id, eventType, token);
                      await CartRepository().addToCart(CartItemRequest(
                          pizzaId: pizza.id, quantity: quantity));
                      await widget.refreshRecommend?.call();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Add to your cart success')),
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token is null')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Add To Cart',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          pizza: pizza,
                          quantity: quantity,
                          size: selectedSize,
                          refreshRecommend: widget.refreshRecommend,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeButton(String size) {
    final isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pizza_management/UI/pizza_screen/pizza_detail.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import 'package:pizza_management/data/repository/auth_repository.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';
import '../../data/ai_recommend/interaction_type.dart';
import '../../data/model/pizza.dart';

class PizzaScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Future<void> Function() refreshRecommend;

  const PizzaScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.refreshRecommend,
  });

  @override
  State<PizzaScreen> createState() => _PizzaScreenState();
}

class _PizzaScreenState extends State<PizzaScreen> {
  late Future<List<Pizza>> _pizzas;
  final PizzaRepository _pizzaRepository = PizzaRepository();

  @override
  void initState() {
    super.initState();
    _pizzas = _pizzaRepository.getPizzaByCategoryId(widget.categoryId);
  }

  String _getStaticRating(int id) {
    double score = 3.8 + (id % 12) * 0.1;
    if (score > 5.0) score = 4.9;
    return score.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7A082),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Pizza>>(
        future: _pizzas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Connection Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No pizzas found in this category 🍕",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 16,
            ),
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: isDesktop ? 20 : 14,
              mainAxisSpacing: isDesktop ? 20 : 14,
              childAspectRatio: isDesktop ? 0.75 : 0.68,
            ),
            itemBuilder: (context, index) {
              final pizza = data[index];
              final rating = _getStaticRating(pizza.id);

              return GestureDetector(
                onTap: () async {
                  final token = await AuthRepository().getToken();
                  final int pizzaId = pizza.id;
                  final String eventType = InteractionType.click;

                  if (token != null) {
                    await AIRepository().trackUserAction(pizzaId, eventType, token);
                    await widget.refreshRecommend();
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login to continue')),
                    );
                  }

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PizzaDetailScreen(
                        pizza: pizza,
                        refreshRecommend: widget.refreshRecommend,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 50,
                        child: Stack(
                          children: [
                            Hero(
                              tag: pizza.id,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(22),
                                ),
                                child: Image.network(
                                  ApiConstant.pizzaImage(pizza.image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: Icon(
                                            Icons.local_pizza,
                                            color: Colors.deepOrange,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            // Badge Rating
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(140),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pizza.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      if (pizza.mainIngredient?.hasCheese == true)
                                        _buildTag(Icons.circle, "Cheese"),
                                      if (pizza.mainIngredient?.hasSeafood == true)
                                        _buildTag(Icons.set_meal, "Seafood"),
                                      if (pizza.mainIngredient?.hasPineapple == true)
                                        _buildTag(Icons.eco, "Pineapple"),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${pizza.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.deepOrange),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.deepOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
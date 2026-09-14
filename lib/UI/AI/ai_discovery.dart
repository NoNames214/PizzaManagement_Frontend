import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/pizza_screen/pizza_detail.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import '../../data/api/api_constant.dart';
import '../../data/model/pizza.dart';

class AIRecommendScreen extends StatefulWidget {
  final String token;

  const AIRecommendScreen({super.key, required this.token});

  @override
  State<AIRecommendScreen> createState() => AIRecommendState();
}

class AIRecommendState extends State<AIRecommendScreen> {
  final logger = Logger();
  final List<dynamic> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    logger.i("AI screen init ${identityHashCode(this)}");
    loadAIData();
  }

  Future<void> loadAIData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AIRepository().getRecommend(widget.token);
      if (mounted) {
        setState(() {
          _data.clear();
          _data.addAll(result);
          _isLoading = false;
        });
      }
      logger.i(result);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      logger.e("Error loading AI data: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "✨ Recommendations",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Based on your recent activities",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _data.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: loadAIData,
      color: Colors.orange,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return _buildAICard(_data[index]);
        },
      ),
    );
  }

  Widget _buildAICard(dynamic item) {
    final Pizza pizza = Pizza(
      id: item['id'] ?? 0,
      name: item['name'] ?? "",
      price: (item['price'] as num?)?.toDouble() ?? 0,
      image: item['image'] ?? "",
      toppingsName: const [],
      mainIngredient: null,
      isGlutenFree: false,
      sauce: "",
      categoryName: "",
    );
    final double score = (item['score'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PizzaDetailScreen(pizza: pizza, refreshRecommend: loadAIData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: pizza.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    ApiConstant.pizzaImage(pizza.image),
                    width: 95,
                    height: 95,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stacktrace) {
                      return Container(
                        width: 95,
                        height: 95,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.local_pizza,
                          size: 40,
                          color: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pizza.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${(score * 10).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "AI Recommended",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${pizza.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
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
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 20),
          Text(
            "AI is finding pizzas you'll love 🍕",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: loadAIData,
      color: Colors.orange,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Icon(Icons.psychology_alt, color: Colors.white38, size: 90),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "No recommendations yet",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Explore more pizzas or pull down to reload",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}

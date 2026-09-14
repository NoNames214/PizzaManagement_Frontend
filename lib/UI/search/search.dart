import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';
import '../pizza_screen/pizza_detail.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function()? refreshRecommend;

  const SearchScreen({
    super.key,
    this.refreshRecommend,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final PizzaRepository _searchRepository = PizzaRepository();

  List<Pizza> pizzas = [];
  Timer? debounce;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPizza(String value) async {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 400),
          () async {
        if (value.trim().isEmpty) {
          if (!mounted) return;

          setState(() {
            pizzas.clear();
          });
          return;
        }

        final result = await _searchRepository.searchPizza(value);
        if (!mounted) return;
        setState(() {
          pizzas = result;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Search Pizza",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: searchController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: "Search pizza...",
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearching
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        pizzas.clear();
                        focusNode.unfocus();
                        setState(() {});
                      },
                    ) : null,
                  ),
                  onChanged: _searchPizza,
                ),
              ),
            ),

            Expanded(
              child: isSearching
                  ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: pizzas.length,
                itemBuilder: (context, index) {
                  final item = pizzas[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ApiConstant.pizzaImage(item.image),
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.soup_kitchen,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(item.sauce),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                size: 16,
                                color: Colors.amber,
                              ),
                              Text(
                                "\$${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PizzaDetailScreen(
                              pizza: item,
                              refreshRecommend:
                              widget.refreshRecommend,
                            ),
                          ),
                        );

                        if (result == true && context.mounted) {
                          focusNode.unfocus();
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  );
                },
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Popular Searches",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _SearchChip("The Classics"),
                        _SearchChip("Ocean's Delight"),
                        _SearchChip("Green Garden"),
                        _SearchChip("Best Seller"),
                        _SearchChip("Meat Feast"),
                        _SearchChip("BBQ"),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Icon(
                      Icons.local_pizza,
                      size: 140,
                      color: Colors.orange.shade200,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Find your favorite pizza 🍕",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String text;

  const _SearchChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      avatar: const Icon(
        Icons.local_pizza_rounded,
        size: 18,
        color: Colors.red,
      ),
      label: Text(text),
    );
  }
}
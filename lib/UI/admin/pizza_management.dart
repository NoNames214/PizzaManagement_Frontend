import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';
import '../../data/api/api_constant.dart';
import '../add/add_pizza.dart';


class PizzaManagement extends StatefulWidget {
  const PizzaManagement({super.key,});

  @override
  State<PizzaManagement> createState() => _PizzaManagementState();
}

class _PizzaManagementState extends State<PizzaManagement> {
  List<Pizza> pizzas = [];
  final PizzaRepository _pizzaRepository = PizzaRepository();
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = true;
  Timer ?debounce;
  final logger = Logger();

  Future<void> loadPizzas() async {
    try {
      final data = await _pizzaRepository.getPizza();
      if (!mounted) return;
      setState(() {
        pizzas = data;
        isLoading = false;
      });
    } catch (e) {
      logger.e("Load Pizzas Failed: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePizza(int id) async {
    try {
      final success = await _pizzaRepository.deletePizza(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Delete pizza successfully"),
            backgroundColor: Colors.green,
          ),
        );
        loadPizzas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Delete failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _searchPizza(String value) async {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(
      const Duration(milliseconds: 400), () async {
        if (value.trim().isEmpty) {
          if (!mounted) return;
          setState(() {
            pizzas.clear();
          });
          return;
        }

        final result = await _pizzaRepository.searchPizza(value);
        if (!mounted) return;
        setState(() {
          pizzas = result;
        });
      },
    );
  }

  Future<void> showDeleteDialog (Pizza pizza) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.red,
              ),
              SizedBox(width: 15),
              Text('Delete Pizza'),
            ],
          ),
          content: Text(
            'Are you sure want to delete ${pizza.name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
    );
    if (confirm == true) {
      deletePizza(pizza.id);
    }
  }

  @override
  void initState() {
    super.initState();
    loadPizzas();
  }

  @override
  void dispose() {
    debounce?.cancel();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Pizza Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPizza(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Pizza"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "Search Pizza",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _textEditingController.clear();
                    loadPizzas();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) => _searchPizza(value),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: pizzas.length,
                itemBuilder: (context, index) {
                  final item = pizzas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              ApiConstant.pizzaImage(item.image),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  item.categoryName,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  "\$${item.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isGlutenFree
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.isGlutenFree
                                        ? "Gluten Free"
                                        : "Normal",
                                    style: TextStyle(
                                      color: item.isGlutenFree
                                          ? Colors.green
                                          : Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)
                                    => AddPizza(pizza: item),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(90, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                onPressed: () => showDeleteDialog(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(90, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text("Delete"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
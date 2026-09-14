import 'package:flutter/material.dart';
import 'package:pizza_management/data/model/category.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/model/topping_name.dart';
import 'package:pizza_management/data/repository/category_repository.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';
import 'package:pizza_management/data/repository/topping_repository.dart';

class AddPizza extends StatefulWidget {
  final Pizza? pizza;

  const AddPizza({super.key, this.pizza});

  @override
  State<AddPizza> createState() => _AddPizzaState();
}

class _AddPizzaState extends State<AddPizza> {
  final PizzaRepository _pizzaRepository = PizzaRepository();
  final ToppingRepository _toppingRepository = ToppingRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  int? selectedCategory;
  bool? isGlutenFree;
  String? selectedSauce;
  final List<int> selectedToppings = [];
  List<Category> categories = [];
  List<Toppings> toppings = [];

  final List<String> sauces = ["Honey", "BBQ"];

  Future<void> addPizza() async {
    try {
      final data = {
        "name": nameController.text,
        "price": double.parse(priceController.text),
        "isGlutenFree": isGlutenFree,
        "sauce": selectedSauce,
        "categoryId": selectedCategory,
        "toppingId": selectedToppings,
      };
      final success = await _pizzaRepository.createPizza(data);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Add pizza successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> updatePizza(int id) async {
    try {
      final data = {
        "name": nameController.text,
        "price": double.parse(priceController.text),
        "isGlutenFree": isGlutenFree,
        "sauce": selectedSauce,
        "categoryId": selectedCategory,
        "toppingId": selectedToppings,
      };
      final success = await _pizzaRepository.updatePizza(id, data);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update pizza successfully")),
        );
        Navigator.pop(context, true);
        loadData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> loadData() async {
    try {
      final category = await _categoryRepository.getCategories();
      final topping = await _toppingRepository.getToppings();
      if (!mounted) return;
      setState(() {
        categories = category;
        toppings = topping;
        if (widget.pizza != null) {
          final categoryId = categories.firstWhere(
            (e) => e.name == widget.pizza!.categoryName,
          );
          selectedCategory = categoryId.id;

          selectedToppings.clear();
          selectedToppings.addAll(
            toppings
                .where((t) => widget.pizza!.toppingsName.contains(t.name))
                .map((t) => t.id),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    if (widget.pizza != null) {
      nameController.text = widget.pizza!.name;
      priceController.text = widget.pizza!.price.toString();

      selectedSauce = widget.pizza!.sauce;
      isGlutenFree = widget.pizza!.isGlutenFree;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.pizza == null ? "Add Pizza" : "Edit Pizza",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: nameController,
              label: "Pizza Name",
              icon: Icons.local_pizza,
            ),

            const SizedBox(height: 18),
            _buildTextField(
              controller: priceController,
              label: "Price",
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 18),

            _buildCategory(),

            const SizedBox(height: 18),

            _buildSauce(),

            const SizedBox(height: 20),

            _buildToppings(),

            const SizedBox(height: 20),
            SwitchListTile(
              value: isGlutenFree ?? false,
              activeColor: Colors.deepOrange,
              title: const Text("Gluten Free"),
              onChanged: (value) {
                setState(() {
                  isGlutenFree = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (widget.pizza == null) {
                    addPizza();
                  } else {
                    updatePizza(widget.pizza!.id);
                  }
                },
                icon: Icon(widget.pizza == null ? Icons.add : Icons.edit),
                label: Text(
                  widget.pizza == null ? "Add Pizza" : "Update Pizza",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildCategory() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: "Category",
        border: OutlineInputBorder(),
      ),
      value: selectedCategory,
      items: categories
          .map(
            (item) => DropdownMenuItem(value: item.id, child: Text(item.name)),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSauce() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Sauce",
        border: OutlineInputBorder(),
      ),
      value: selectedSauce,
      items: sauces
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedSauce = value;
        });
      },
    );
  }

  Widget _buildToppings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Toppings", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: toppings.map((item) {
            return FilterChip(
              label: Text(item.name),
              selected: selectedToppings.contains(item.id),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selectedToppings.add(item.id);
                  } else {
                    selectedToppings.remove(item.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

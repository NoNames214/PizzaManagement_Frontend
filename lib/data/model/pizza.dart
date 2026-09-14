import 'package:pizza_management/data/model/main_ingredient.dart';

class Pizza {
  final int id;
  final String name;
  final double price;
  final bool isGlutenFree;
  final String sauce;
  final String categoryName;
  final String image;
  final MainIngredient ? mainIngredient;
  final List<String> toppingsName;

  Pizza({
    required this.id,
    required this.name,
    required this.price,
    required this.isGlutenFree,
    required this.sauce,
    required this.categoryName,
    required this.image,
    required this.mainIngredient,
    required this.toppingsName
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pizza && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Pizza.fromJson(Map<String, dynamic> json) {
    return Pizza(
      id: json['id'],
      name: json['name'] ?? "",
      price: json['price'].toDouble(),
      isGlutenFree: json['isGlutenFree'],
      sauce: json['sauce'] ?? "",
      categoryName: json['categoryName'] ?? "",
      image: json['image'] ?? "",
      mainIngredient: json['mainIngredient'] != null
          ? MainIngredient.fromJson(json['mainIngredient'])
          : null,
      toppingsName: json['toppingNames'] != null
          ? List<String>.from(json['toppingNames'])
          : [],
    );
  }

  @override
  String toString() => 'Pizza(id : $id, name : $name, price : $price)';
}
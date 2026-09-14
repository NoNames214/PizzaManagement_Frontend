class PizzaRequest {
  final String name;
  final double price;
  final bool isGlutenFree;
  final String sauce;
  final int categoryId;
  final List<int> toppingId;

  PizzaRequest({
    required this.name,
    required this.price,
    this.isGlutenFree = false,
    required this.sauce,
    required this.categoryId,
    required this.toppingId
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "isGlutenFree": isGlutenFree,
      "sauce": sauce,
      "categoryId": categoryId,
      "toppingId": toppingId
    };
  }
}
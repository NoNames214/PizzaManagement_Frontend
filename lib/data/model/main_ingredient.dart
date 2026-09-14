class MainIngredient {
  final bool hasPineapple;
  final bool hasCheese;
  final bool hasSeafood;
  final double spicinessLevel;
  final double crustType;
  final double size;
  final double priceRange;

  MainIngredient({
    required this.hasPineapple,
    required this.hasCheese,
    required this.hasSeafood,
    required this.spicinessLevel,
    required this.crustType,
    required this.size,
    required this.priceRange
  });

  factory MainIngredient.fromJson(Map<String, dynamic> json) {
    return MainIngredient(
      hasPineapple: json['hasPineapple'] == true,
      hasCheese: json['hasCheese'] == true,
      hasSeafood: json['hasSeafood'] == true,
      spicinessLevel: (json['spicinessLevel'] as num?)?.toDouble() ?? 0.0,
      crustType: (json['crustType'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      priceRange: (json['priceRange'] as num?)?.toDouble() ?? 0.0
    );
  }
}
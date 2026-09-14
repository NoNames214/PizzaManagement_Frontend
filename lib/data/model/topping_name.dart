class Toppings {
  final int id;
  final String name;

  Toppings({
    required this.id,
    required this.name
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Toppings && runtimeType == other.runtimeType &&
              id == other.id;
  @override
  int get hashCode => id.hashCode;


  factory Toppings.fromJson(Map<String, dynamic> json) {
    return Toppings(
      id: json['id'],
      name: json['name'] ?? ""
    );
  }

  @override
  String toString() => 'Toppings(id : $id, name : $name)';

}
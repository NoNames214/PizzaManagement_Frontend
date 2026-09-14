import 'package:logger/logger.dart';
import 'package:pizza_management/data/service/topping_service.dart';
import '../model/topping_name.dart';

class ToppingRepository {
  final logger = Logger();
  final ToppingService _toppingService = ToppingService();

  Future<List<Toppings>> getToppings() async {
    try {
      return await _toppingService.getTopping();
    }
    catch (e) {
      logger.e("Get Topping Failed: $e");
      return [];
    }
  }
}
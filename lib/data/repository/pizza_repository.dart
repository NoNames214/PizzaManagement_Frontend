import 'package:logger/logger.dart';
import 'package:pizza_management/data/service/pizza_service.dart';
import '../model/pizza.dart';

class PizzaRepository {
  final PizzaService _pizzaService = PizzaService();
  final logger = Logger();
  
  Future<List<Pizza>> getPizza() async {
    try {
      return await _pizzaService.getPizza();
    }
    catch (e) {
      logger.e("Get Pizza Failed: $e");
      return [];
    }
  }

  Future<List<Pizza>> getPizzaByCategoryId(int categoryId) async {
    try {
      return await _pizzaService.getPizzaByCategoryId(categoryId);
    }
    catch (e) {
      logger.e("Get Pizza Failed: $e");
      return [];
    }
  }

  Future<bool> createPizza(Map<String, dynamic> data) async {
    try {
      return await _pizzaService.createPizza(data);
    }
    catch (e) {
      logger.e("Create Pizza Failed: $e");
      return false;
    }
  }

  Future<bool> deletePizza(int id) async {
    try {
      return await _pizzaService.deletePizza(id);
    }
    catch (e) {
      logger.e("Delete Pizza Failed: $e");
      return false;
    }
  }

  Future<bool> updatePizza (int id, Map<String, dynamic> data) async {
    try {
      return await _pizzaService.updatePizza(id, data);
    }
    catch (e) {
      logger.e("Update Pizza Failed: $e");
      return false;
    }
  }

  Future<List<Pizza>> searchPizza(String keyword) async {
    try {
      return await _pizzaService.searchPizza(keyword);
    }
    catch (e) {
      logger.e("Search Pizza Failed: $e");
      return [];
    }
  }

}
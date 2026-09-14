import 'package:dio/dio.dart';
import 'package:pizza_management/data/model/pizza.dart';
import '../interceptor/dio_client.dart';

class PizzaService {
  static final PizzaService _pizzaService = PizzaService._internal();
  factory PizzaService() => _pizzaService;
  PizzaService._internal();

  final _dio = DioClient().dio;

  Future<List<Pizza>> getPizza() async {
    try {
      final response = await _dio.get(
        'Pizza',
        queryParameters: {
          'pageNumber': 1,
          'pageSize': 20,
        }
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Pizza.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<List<Pizza>> getPizzaByCategoryId(int categoryId) async {
    try {
      final response = await _dio.get(
          'Pizza/category/$categoryId',
          queryParameters: {
            'pageNumber': 1,
            'pageSize': 20,
          }
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Pizza.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.data}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> createPizza(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        'Pizza',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.response!.data);
    }
  }

  Future<bool> deletePizza (int id) async {
    try {
      final response = await _dio.delete('Pizza/$id');
      if (response.statusCode == 204) {
        return true;
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> updatePizza(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
          'Pizza/$id',
          data: data
      );
      if (response.statusCode == 204) {
        return true;
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.response?.data);
    }
  }

  Future<List<Pizza>> searchPizza(String keyword) async {
    try {
      final response = await _dio.get(
          'Pizza/search',
          queryParameters: {
            'keyword': keyword,
          }
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Pizza.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';
import 'package:pizza_management/data/model/topping_name.dart';

class ToppingService {
  static final ToppingService _toppingService = ToppingService._internal();
  factory ToppingService() => _toppingService;
  ToppingService._internal();

  final _dio = DioClient().dio;

  Future<List<Toppings>> getTopping() async {
    try {
      final response = await _dio.get('Topping');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Toppings.fromJson(json)).toList();
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
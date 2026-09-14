import 'package:dio/dio.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';
import 'package:pizza_management/data/model/category.dart';

class CategoryService {
  static final CategoryService _categoryService = CategoryService._internal();
  factory CategoryService() => _categoryService;
  CategoryService._internal();

  final _dio = DioClient().dio;

  Future<List<Category>> getCategory() async {
    try {
      final response = await _dio.get('Category');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
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
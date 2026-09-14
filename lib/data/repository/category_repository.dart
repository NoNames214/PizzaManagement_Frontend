import 'package:logger/logger.dart';
import '../model/category.dart';
import '../service/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService = CategoryService();
  final logger = Logger();

  Future<List<Category>> getCategories() async {
    try {
      return await _categoryService.getCategory();
    }
    catch (e) {
      logger.e("Get Category Failed: $e");
      return [];
    }
  }
}
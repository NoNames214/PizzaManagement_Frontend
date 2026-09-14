import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';

class AIRecommend {
  static final AIRecommend _aiRecommend = AIRecommend._internal();
  factory AIRecommend() => _aiRecommend;
  AIRecommend._internal();

  final _dio = DioClient().dio;
  final logger = Logger();

  Future<List<dynamic>> getRecommend(String token) async {
    try {
      final response = await _dio.get(
          "AI/recommend",
          options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              }
          )
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return List<dynamic>.from(data['actions']);
      }
      logger.e(response.data);
      return [];
    }
    catch (e) {
      throw Exception(e);
    }
  }

  Future<void> trackUserAction(int pizzaId, String eventType, String token) async {
    try {
      final response = await _dio.post(
        'AI/track',
        data:{
          "pizzaId" : pizzaId,
          "eventType" : eventType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          }
        )
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to track user action');
      }
    }
    catch (e) {
      throw Exception(e);
    }
  }
}
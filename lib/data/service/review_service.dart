import 'package:dio/dio.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';
import 'package:pizza_management/data/model/review.dart';
import 'package:pizza_management/data/request/review_request.dart';

class ReviewService {
  static final ReviewService _reviewService = ReviewService._internal();
  factory ReviewService() => _reviewService;
  ReviewService._internal();

  final _dio = DioClient().dio;
  
  Future<List<Review>> getReview() async {
    try {
      final response = await _dio.get('Review');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> addReview(ReviewRequest request) async {
    try {
      final response = await _dio.post(
        'Review',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<bool> deleteReview (int id) async {
    try {
      final response = await _dio.delete('Review/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
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

  Future<bool> updateReview (int id) async {
    try {
      final response = await _dio.put('Review/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch(e) {
      throw Exception(e.message);
    }
  }
}
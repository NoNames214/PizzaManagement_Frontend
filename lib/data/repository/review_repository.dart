import 'package:logger/logger.dart';
import 'package:pizza_management/data/service/review_service.dart';
import '../model/review.dart';
import '../request/review_request.dart';

class ReviewRepository {
  final logger = Logger();
  final ReviewService _reviewService = ReviewService();

  Future<List<Review>> getReview() async {
    try {
      return await _reviewService.getReview();
    }
    catch (e) {
      logger.e("Get Review Failed: $e");
      return [];
    }
  }

  Future<bool> addReview(ReviewRequest request) async {
    try {
      return await _reviewService.addReview(request);
    }
    catch(e) {
      logger.e('Add Review Failed: $e');
      return false;
    }
  }

  Future<bool> deleteReview (int id) async {
    try {
      return await _reviewService.deleteReview(id);
    }
    catch(e) {
      logger.e('Delete Review Failed: $e');
      return false;
    }
  }

  Future<bool> updateReview (int id) async {
    try {
      return await _reviewService.updateReview(id);
    }
    catch(e) {
      logger.e('Update Review Failed: $e');
      return false;
    }
  }
}
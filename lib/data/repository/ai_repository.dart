import 'package:logger/logger.dart';
import '../service/ai_recommend_service.dart';

class AIRepository {
  final AIRecommend _aiRecommend = AIRecommend();
  final logger = Logger();

  Future<List<dynamic>> getRecommend(String token) async {
    try {
      return await _aiRecommend.getRecommend(token);
    }
    catch(e) {
      logger.e('Get Recommend Failed: $e');
      return [];
    }
  }

  Future<void> trackUserAction(int pizzaId, String eventType, String token) async {
    try {
      return await _aiRecommend.trackUserAction(pizzaId, eventType, token);
    }
    catch (e) {
      logger.e('Track User Action Failed: $e');
    }
  }
}
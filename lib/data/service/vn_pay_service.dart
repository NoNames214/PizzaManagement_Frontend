import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../interceptor/dio_client.dart';

class VnPayService {

  static final VnPayService _vnPayService = VnPayService._internal();
  factory VnPayService() => _vnPayService;
  VnPayService._internal();

  final dio = DioClient().dio;
  final logger = Logger();

  Future<String> createPaymentUrl (int orderId) async {
    try {
      final response = await dio.post('/VnPay/create-payment-url/$orderId');
      if (response.statusCode == 200) {
        final paymentUrl = response.data['paymentUrl'] ?? response.data['PaymentUrl'];

        if (paymentUrl is String && paymentUrl.isNotEmpty) {
          return paymentUrl;
        }
        throw Exception('Failed to create payment Url');
      } else {
        throw Exception('Failed to create payment url');
      }
    }
    on DioException catch (e) {
      logger.e("${e.response?.data}");
      rethrow;
    }
  }
}
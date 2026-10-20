import '../service/vn_pay_service.dart';

class VnPayRepository {
  final VnPayService _vnPayService;

  VnPayRepository(this._vnPayService);

  Future<String> createPaymentUrl(int orderId) async {
    return await _vnPayService.createPaymentUrl(orderId);
  }
}
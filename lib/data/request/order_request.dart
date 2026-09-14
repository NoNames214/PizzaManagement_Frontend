import 'package:pizza_management/data/request/order_details_request.dart';

class OrderRequest {
  final List<OrderDetailsRequest> detailsRequest;

  OrderRequest({
    required this.detailsRequest
  });

  Map<String, dynamic> toJson() {
    return {
      'detailsRequests': detailsRequest.map((e) => e.toJson()).toList()
    };
  }
}
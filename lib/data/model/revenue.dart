import 'package:pizza_management/data/model/revenue_chart.dart';

class Revenue {
  final DateTime? fromDate;
  final DateTime? toDate;
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final List<RevenueChart> chart;

  Revenue({
    this.fromDate,
    this.toDate,
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.averageOrderValue = 0,
    this.chart = const [],
  });

  factory Revenue.fromJson(Map<String, dynamic> json) {
    return Revenue(
      fromDate: json['fromDate'] != null
          ? DateTime.parse(json['fromDate'])
          : null,
      toDate: json['toDate'] != null
          ? DateTime.parse(json['toDate'])
          : null,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      chart: (json['chart'] as List)
          .map((e) => RevenueChart.fromJson(e))
          .toList(),
    );
  }
}
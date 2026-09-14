class RevenueChart {
  final int year;
  final int month;
  final double revenue;

  RevenueChart({
    required this.year,
    required this.month,
    required this.revenue,
  });

  factory RevenueChart.fromJson(Map<String, dynamic> json) {
    return RevenueChart(
      year: json['year'],
      month: json["month"],
      revenue: (json["revenue"] as num).toDouble(),
    );
  }
}
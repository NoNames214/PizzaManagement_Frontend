import 'package:flutter/material.dart';
import 'package:pizza_management/data/repository/admin_repository.dart';

class RevenueManagement extends StatefulWidget {
  const RevenueManagement({super.key});

  @override
  State<RevenueManagement> createState() => _RevenueManagementState();
}

class _RevenueManagementState extends State<RevenueManagement> {
  final AdminRepository _adminRepository = AdminRepository();
  double totalRevenue = 0;
  double averageOrderValue = 0;
  int totalOrders = 0;
  bool isLoading = true;
  late DateTime startDate = DateTime(DateTime.now().year, DateTime.june, 1);
  late DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await _adminRepository.getRevenue(startDate, endDate);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        totalRevenue = data.totalRevenue;
        averageOrderValue = data.averageOrderValue;
        totalOrders = data.totalOrders;
        startDate = data.fromDate!;
        endDate = data.toDate!;
      });
    }
    catch(e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Revenue Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            _buildRevenueCard(),
            const SizedBox(height: 20),

            _buildOrderCard(),
            const SizedBox(height: 20),

            _buildAverageOrderCard(),
            const SizedBox(height: 20),

            _buildRevenueItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Revenue",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 5),
              Text(
                "${totalRevenue.toStringAsFixed(2)} \$",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag,
            color: Colors.deepOrange,
            size: 35,
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Orders"),
              SizedBox(height: 4),
              Text(
                "$totalOrders",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAverageOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long,
              color: Colors.deepOrange, size: 35),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Average Order"),
              Text(
                "${averageOrderValue.toStringAsFixed(0)} \$",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(
            Icons.calendar_month,
            color: Colors.green,
          ),
        ),
        title: Text(
          "To: ${startDate.day.toString().padLeft(2, '0')}/${startDate.month}/${startDate.year} \n"
              "End: ${endDate.day}/${endDate.month}/${endDate.year}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Total Order: $totalOrders",
        ),
        trailing: Text(
          "Total Revenue: ${totalRevenue.toStringAsFixed(2)} \$",
          style: TextStyle(
            color: Colors.deepOrange,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
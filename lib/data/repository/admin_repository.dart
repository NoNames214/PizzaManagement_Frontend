import 'package:logger/logger.dart';
import 'package:pizza_management/data/service/admin_service.dart';
import '../model/revenue.dart';
import '../model/user.dart';

class AdminRepository {
  final AdminService _adminService = AdminService();
  final logger = Logger();

  Future<List<User>> getUser() async {
    try {
      return await _adminService.getUser();
    }
    catch(e) {
      logger.e('Get User Failed: $e');
      return [];
    }
  }

  Future<Revenue> getRevenue(DateTime ? startDate, DateTime ? endDate) async {
    try {
      return await _adminService.getRevenue(startDate, endDate);
    }
    catch(e) {
      logger.e('Get Revenue Failed: $e');
      return Revenue();
    }
  }

  Future<int> totalUser() async {
    try {
      return await _adminService.totalUser();
    }
    catch (e) {
      logger.e('Get Total User Failed: $e');
      return 0;
    }
  }

  Future<bool> lockUser(int id) async {
    try {
      return await _adminService.lockUser(id);
    } catch (e) {
      logger.e('Lock User Failed: $e');
      return false;
    }
  }

  Future<bool> unlockUser(int id) async {
    try {
      return await _adminService.unlockUser(id);
    } catch (e) {
      logger.e('Unlock User Failed: $e');
      return false;
    }
  }
}
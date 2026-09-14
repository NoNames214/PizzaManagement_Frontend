import 'package:dio/dio.dart';
import 'package:pizza_management/data/model/revenue.dart';
import 'package:pizza_management/data/model/user.dart';
import '../interceptor/dio_client.dart';

class AdminService {
  static final AdminService _adminService = AdminService._internal();

  factory AdminService() => _adminService;

  AdminService._internal();

  final _dio = DioClient().dio;

  Future<List<User>> getUser() async {
    try {
      final response = await _dio.get('Admin/user-list');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => User.fromJson(e))
            .toList();
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }


  Future<Revenue> getRevenue(DateTime ? startDate, DateTime ? endDate) async {
    try {
      final response = await _dio.get(
        'Admin/revenue',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Revenue.fromJson(response.data);
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<int> totalUser() async {
    try {
      final response = await _dio.get('Admin/status/user-count');
      if (response.statusCode == 200) {
        return response.data['totalCount'];
      }
      else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    }
    on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> lockUser(int id) async {
    try {
      final response = await _dio.put('Admin/lock/$id');
      if (response.statusCode == 204) {
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

  Future<bool> unlockUser (int id) async {
    try {
      final response = await _dio.put('Admin/unlock/$id');
      if (response.statusCode == 204) {
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
}
import 'package:dio/dio.dart';
import 'package:pizza_management/data/request/profile_request.dart';
import '../interceptor/dio_client.dart';

class ProfileService {
  static final ProfileService _profileService = ProfileService._internal();
  factory ProfileService() => _profileService;
  ProfileService._internal();

  final _dio = DioClient().dio;

  Future<bool> updateProfile(ProfileRequest request) async {
    try {
      final response = await _dio.put('User/profile',
        data: request.toJson(),
      );
      if (response.statusCode != 204) {
        throw Exception("Update Failed");
      }
      return true;
    }
    on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ??
            e.message ??
            "Unknown Error",
      );
    }
  }
}
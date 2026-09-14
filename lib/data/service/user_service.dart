import 'package:dio/dio.dart';
import 'package:pizza_management/data/interceptor/dio_client.dart';
import 'package:pizza_management/data/model/user.dart';

class UserService {
  static final UserService _userService = UserService._internal();
  factory UserService() => _userService;
  UserService._internal();

  final _dio = DioClient().dio;

  Future<User> getUser() async {
    try {
      final response = await _dio.get('User/profile');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);  
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
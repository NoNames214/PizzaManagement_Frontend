import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../interceptor/dio_client.dart';

class AuthService {
  final _dio = DioClient().dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  static final AuthService _authService = AuthService._internal();
  factory AuthService() => _authService;
  AuthService._internal();


  Future<bool> login(String userName, String passWord) async {
    try {
      final response = await _dio.post(
          'Auth/login', data: {
        "userName": userName,
        "passWord": passWord
      });
      logger.i(response.data);
      if (response.statusCode == 200) {
        await _storage.write(key: 'accessToken', value: response.data['token']);
        await _storage.write(key: 'refreshToken', value: response.data['refreshToken']);
        return true;
      }

      return false;
    } catch (e) {
      logger.e("Login Error: $e");
      return false;
    }
  }

  Future<bool> register (String userName, String passWord,
      String email, String fullName) async {
    try {
      final response = await _dio.post(
          'Auth/register', data: {
        "userName": userName,
        "passWord": passWord,
        "email": email,
        "fullName": fullName
      });
      logger.i(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch(e) {
      logger.e("Register Error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      final accessToken = await _storage.read(key: 'accessToken');
      final response = await _dio.post('Auth/refresh',
          data: {
            "accessToken": accessToken,
            "refreshToken": refreshToken
          });
      if (response.statusCode == 200) {
        await _storage.write(
            key: 'accessToken', value: response.data['accessToken']);
        return true;
      }
    } catch (e) {
      logger.e("Refresh Token Failed: $e");
      return false;
    }
    return false;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }
}
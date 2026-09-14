import 'package:logger/logger.dart';
import '../service/auth_service.dart';

class AuthRepository {
  final logger = Logger();
  final AuthService _authService = AuthService();

  Future<bool> login(String userName, String passWord) async {
    try {
      return await _authService.login(userName, passWord);
    }
    catch (e) {
      logger.e("Login Failed: $e");
      return false;
    }
  }
  Future<bool> register(String userName, String passWord, String email, String fullName) async {
    try {
      return await _authService.register(userName, passWord, email, fullName);
    }
    catch(e) {
      logger.e("Register Failed: $e");
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      return await _authService.refreshToken();
    }
    catch(e) {
      logger.e("Refresh Token Failed: $e");
      return false;
    }
  }

  Future<void> logout () async {
    await _authService.logout();
  }

  Future<String?> getToken() async {
    try {
      return await _authService.getToken();
    }
    catch(e) {
      logger.e("Get Token Failed: $e");
      return "";
    }
  }
}
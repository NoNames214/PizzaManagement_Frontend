import 'package:logger/logger.dart';
import '../model/user.dart';
import '../service/user_service.dart';

class UserRepository {
  final UserService _userService = UserService();
  final logger = Logger();

  Future<User> getUser() async {
    try {
      return await _userService.getUser();
    }
    catch (e) {
      logger.e("Get User Failed: $e");
      return User(id: 0, userName: "", email: "", address: "", avatarUrl: "", fullName: "", role: "");
    }
  }

}
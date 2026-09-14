import 'package:logger/logger.dart';
import '../request/profile_request.dart';
import '../service/profile_service.dart';

class ProfileRepository {

  final logger = Logger();
  final ProfileService _profileService = ProfileService();

  Future<bool> updateProfile(ProfileRequest request) async {
    try {
      return await _profileService.updateProfile(request);
    }
    catch (e) {
      logger.e("Update Profile Failed: $e");
      return false;
    }
  }
}
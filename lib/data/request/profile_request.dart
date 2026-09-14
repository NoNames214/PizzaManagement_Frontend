class ProfileRequest {
  final String fullName;
  final String email;
  final String address;
  final String avatarUrl;

  ProfileRequest({
   required this.fullName,
   required this.email,
   required this.address,
   required this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "address": address,
      "avatarUrl": avatarUrl,
    };
  }
}
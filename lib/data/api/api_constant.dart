class ApiConstant {
  static const String baseUrl = "http://192.168.1.199:5192";
  static const String apiUrl = "$baseUrl/api/";

  static String pizzaImage (String fileName) {
    return "$baseUrl$fileName";
  }
  static String categoryImage (String fileName) {
    return "$baseUrl$fileName";
  }
  static String profileImage (String fileName) {
    return "$baseUrl$fileName";
  }
}
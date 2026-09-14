class ApiConstant {
  static const String baseUrl = "https://localhost:7065";
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
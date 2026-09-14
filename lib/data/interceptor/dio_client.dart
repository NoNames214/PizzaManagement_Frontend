import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_constant.dart';

class DioClient {
  late Dio dio;
  final Dio _refreshDio = Dio(BaseOptions(baseUrl: ApiConstant.apiUrl));
  final storage = const FlutterSecureStorage();

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstant.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _setupSSL(dio);
    _setupSSL(_refreshDio);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.path.contains('Auth/login')) {
          return handler.next(options);
        }
        final token = await storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          bool success = await _refreshToken();
          if (success) {
            return handler.resolve(await _retry(e.requestOptions));
          }
        }
        return handler.next(e);
      },
    ));
  }

  void _setupSSL(Dio dioInstance) {
    (dioInstance.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      if (kDebugMode) {
        client.badCertificateCallback = (cert, host, port) => true;
      }
      return client;
    };
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refreshToken');
      final accessToken = await storage.read(key: 'accessToken');
      final response = await _refreshDio.post('Auth/refresh',
          data: {
            "accessToken": accessToken,
            "refreshToken": refreshToken
          });
      if (response.statusCode == 200) {
        await storage.write(key: 'accessToken', value: response.data['accessToken']);
        await storage.write(key: 'refreshToken', value: response.data['refreshToken']);
        return true;
      }
    } catch (e) {
      await storage.deleteAll();
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options (
        method: requestOptions.method,
        headers: requestOptions.headers
    );
    final token = await storage.read(key: 'accessToken');
    options.headers!['Authorization'] = 'Bearer $token';
    return dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options
    );
  }
}
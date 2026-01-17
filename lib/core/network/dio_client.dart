// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final storage = const FlutterSecureStorage();

  // Add this method to set a token for testing purposes
  void setTokenForTest(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.37.59/seamless_call/',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // If a token is already set for testing, don't try to read from storage
          if (options.headers.containsKey('Authorization')) {
            return handler.next(options);
          }
          final token = await storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) => handler.next(e),
      ),
    );
  }
}

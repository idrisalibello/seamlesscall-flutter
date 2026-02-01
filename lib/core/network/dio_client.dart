import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // NEW: App-layer callback for auth expiry (wired in main.dart)
  static void Function()? onAuthExpired;

  // Optional testing helper
  void setTokenForTest(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://172.19.238.59/seamless_call/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor first for comprehensive logging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true, // Log request body
        responseBody: true, // Log response body
        logPrint: (obj) => print(obj.toString()), // Use print directly
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // If a token is already set for testing or per-request, keep it.
          if (options.headers.containsKey('Authorization')) {
            return handler.next(options);
          }

          final token = await storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            // Do NOT navigate/logout here. Signal app layer instead.
            onAuthExpired?.call();
          }
          return handler.next(e);
        },
      ),
    );
  }
}

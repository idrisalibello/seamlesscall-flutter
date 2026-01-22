import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/main.dart'; // Import for navigatorKey

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
        baseUrl: 'http://10.136.238.59/seamless_call/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 15),
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
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            final responseData = e.response?.data;
            if (responseData is Map &&
                responseData['error'] == 'Invalid or expired token') {
              final context = navigatorKey.currentContext;
              final navigator = navigatorKey.currentState;

              if (context != null && navigator != null) {
                // Use a post-frame callback to avoid issues with building widgets
                // while another build is in progress.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout(navigator);
                });
              }
              // It's often best to let the original error propagate so the UI layer
              // that made the request can still handle the error (e.g., stop a loading spinner).
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}

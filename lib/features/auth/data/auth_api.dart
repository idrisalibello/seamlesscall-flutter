import 'package:dio/dio.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';

class AuthApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.57.142.59/seamless_call/public/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      final resp = await _dio.post(
        '/api/v1/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = resp.data;

        if (body == null || body['data'] == null) {
          throw Exception('Invalid response: missing data object');
        }

        final userJson = body['data']['user'];

        if (userJson == null) {
          throw Exception('Registration succeeded but user payload is null');
        }

        return AppUser.fromJson(Map<String, dynamic>.from(userJson));
      }

      throw Exception(
        'Registration failed with status ${resp.statusCode}: ${resp.data}',
      );
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'Registration failed: ${e.response?.statusCode} ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during registration: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post(
        '/api/v1/login',
        data: {'email_or_phone': email, 'password': password},
      );

      if (resp.statusCode == 200) {
        return Map<String, dynamic>.from(resp.data['data']);
      } else {
        throw Exception(
          'Login failed with status code ${resp.statusCode}: ${resp.data}',
        );
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'Login failed: ${e.response?.statusCode} ${e.response?.data}',
        );
      } else if (e.type == DioErrorType.connectionTimeout) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';

class AuthApi {
  final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'http://10.88.93.59/seamless_call/public/api/v1',
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              print('REQUEST[${options.method}] => PATH: ${options.path}');
              print('REQUEST[${options.method}] => URL: ${options.uri}');
              print('Headers: ${options.headers}');
              print('Data: ${options.data}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              print(
                'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
              );
              print('Response Data: ${response.data}');
              return handler.next(response);
            },
            onError: (DioError e, handler) {
              print(
                'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
              );
              print('Error Message: ${e.message}');
              print('Error Response Data: ${e.response?.data}');
              return handler.next(e);
            },
          ),
        );

  Future<Map<String, dynamic>> applyAsProvider({
    required String token,
    required String companyName,
    required String location,
    required String services,
  }) async {
    try {
      final resp = await _dio.post(
        '/auth/apply-as-provider',
        data: {
          'company_name': companyName,
          'location': location,
          'services': services,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (resp.statusCode == 200) {
        return Map<String, dynamic>.from(resp.data);
      } else {
        throw Exception(
          'Application failed with status code ${resp.statusCode}: ${resp.data}',
        );
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'Application failed: ${e.response?.statusCode} ${e.response?.data['messages']['error'] ?? e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during application: $e');
    }
  }


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
        '/register',
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
    required String identifier, // Changed from email to identifier
    required String password,
  }) async {
    try {
      final resp = await _dio.post(
        '/login',
        data: {'email_or_phone': identifier, 'password': password},
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
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }

  Future<void> requestLoginOtp(String identifier) async {
    try {
      final resp = await _dio.post(
        '/auth/otp/request',
        data: {'identifier': identifier},
      );
      if (resp.statusCode != 200) {
        throw Exception('Failed to request OTP: ${resp.data}');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'Request OTP failed: ${e.response?.statusCode} ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during OTP request: $e');
    }
  }

  Future<String> loginWithOtp(String identifier, String otp) async {
    try {
      final resp = await _dio.post(
        '/auth/otp/login',
        data: {'identifier': identifier, 'otp': otp},
      );
      if (resp.statusCode == 200) {
        return resp.data['token'] as String;
      } else {
        throw Exception(
          'OTP login failed with status code ${resp.statusCode}: ${resp.data}',
        );
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'OTP login failed: ${e.response?.statusCode} ${e.response?.data}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        throw Exception('OTP login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during OTP login: $e');
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    try {
      final resp = await _dio.post(
        '/auth/oauth',
        data: {'provider': provider, 'token': token},
      );

      if (resp.statusCode == 200) {
        return Map<String, dynamic>.from(resp.data['data']);
      } else {
        throw Exception(
          'Social login failed with status code ${resp.statusCode}: ${resp.data}',
        );
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(
          'Social login failed: ${e.response?.statusCode} ${e.response?.data}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Please try again.');
      } else {
        throw Exception('Social login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error during social login: $e');
    }
  }
}

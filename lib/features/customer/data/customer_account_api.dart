import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';

class CustomerAccountApi {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<String?> _token() async {
    return _storage.read(key: 'auth_token');
  }

  Future<AppUser> fetchProfile() async {
    final token = await _token();

    final resp = await _dio.get(
      'api/v1/customer/account/profile',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return AppUser.fromJson(
      Map<String, dynamic>.from(resp.data['data']),
    );
  }

  Future<AppUser> updateName(String name) async {
    final token = await _token();

    final resp = await _dio.post(
      'api/v1/customer/account/update-profile',
      data: {
        'name': name,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return AppUser.fromJson(
      Map<String, dynamic>.from(resp.data['data']),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await _token();

    await _dio.post(
      'api/v1/customer/account/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
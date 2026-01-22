import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/system/data/models/permission.dart';
import 'package:seamlesscall/features/system/data/models/role.dart';

class SystemRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Role>> getRoles() async {
    try {
      final response = await _dio.get('/api/v1/system/roles');
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }

  Future<List<AppUser>> getUsers() async {
    try {
      final response = await _dio.get('/api/v1/admin/users');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AppUser.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<AppUser> getUserDetails(int userId) async {
    try {
      final response = await _dio.get('/api/v1/admin/users/$userId');
      return AppUser.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      await _dio.put('/api/v1/admin/users/$userId', data: data);
    } on DioException catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<Role>> getUserRoles(int userId) async {
    try {
      final response = await _dio.get('/api/v1/admin/users/$userId/roles');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Role.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load user roles: $e');
    }
  }

  Future<void> updateUserRoles(int userId, List<int> roleIds) async {
    try {
      await _dio.put(
        '/api/v1/admin/users/$userId/roles',
        data: {'role_ids': roleIds},
      );
    } on DioException catch (e) {
      throw Exception('Failed to update user roles: $e');
    }
  }

  Future<Role> createRole({required String name, String? description}) async {
    try {
      final response = await _dio.post(
        '/api/v1/system/roles',
        data: {'role_name': name, 'description': description},
      );
      return Role(id: response.data['id'], roleName: name, description: description);
    } on DioException catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  Future<List<Permission>> getPermissions() async {
    try {
      final response = await _dio.get('/api/v1/system/permissions');
      final List<dynamic> data = response.data;
      return data.map((json) => Permission.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load permissions: $e');
    }
  }

  Future<List<Permission>> getRolePermissions(int roleId) async {
    try {
      final response = await _dio.get('/api/v1/system/roles/$roleId/permissions');
      final List<dynamic> data = response.data;
      return data.map((json) => Permission.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load role permissions: $e');
    }
  }

  Future<void> updateRolePermissions(int roleId, List<int> permissionIds) async {
    try {
      await _dio.put(
        '/api/v1/system/roles/$roleId/permissions',
        data: {'permission_ids': permissionIds},
      );
    } on DioException catch (e) {
      throw Exception('Failed to update permissions: $e');
    }
  }
}

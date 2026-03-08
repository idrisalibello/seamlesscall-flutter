import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/config/data/models/availability_rule_model.dart';

class AvailabilityRepository {
  final DioClient _dioClient = DioClient();

  Future<List<AvailabilityRule>> getAvailabilityRules({
    int? categoryId,
    String? status,
    String? q,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'category_id': categoryId,
        'status': status,
        'q': q,
      }..removeWhere(
          (key, value) => value == null || value.toString().trim().isEmpty);

      final response = await _dioClient.dio.get(
        '/api/v1/admin/coverage-rules',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map(
              (e) => AvailabilityRule.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList();
      }

      throw Exception(
        'Failed to load availability rules. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load availability rules: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AvailabilityRule> getAvailabilityRule(int id) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/admin/coverage-rules/$id',
      );
      if (response.statusCode == 200) {
        return AvailabilityRule.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception(
        'Failed to load availability rule. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load availability rule: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AvailabilityRule> createAvailabilityRule(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/coverage-rules',
        data: payload,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return AvailabilityRule.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception(
        'Failed to create availability rule. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to create availability rule: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AvailabilityRule> updateAvailabilityRule(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/v1/admin/coverage-rules/$id',
        data: payload,
      );
      if (response.statusCode == 200) {
        return AvailabilityRule.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception(
        'Failed to update availability rule. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update availability rule: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AvailabilityRule> updateAvailabilityStatus(int id, String status) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/coverage-rules/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return AvailabilityRule.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception(
        'Failed to update availability rule status. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update availability rule status: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteAvailabilityRule(int id) async {
    try {
      final response = await _dioClient.dio.delete(
        '/api/v1/admin/coverage-rules/$id',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete availability rule. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to delete availability rule: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/config/data/models/promotion_model.dart';

class PromotionRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Promotion>> getPromotions({
    String? q,
    String? promotionType,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{
        'q': q,
        'promotion_type': promotionType,
        'status': status,
      }..removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

      final response = await _dioClient.dio.get(
        '/api/v1/admin/promotions',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Promotion.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception('Failed to load promotions. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load promotions: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Promotion> getPromotion(int id) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/promotions/$id');

      if (response.statusCode == 200) {
        return Promotion.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception('Failed to load promotion. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load promotion: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/promotions',
        data: promotion.toPayload(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Promotion.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception('Failed to create promotion. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to create promotion: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Promotion> updatePromotion(int id, Promotion promotion) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/v1/admin/promotions/$id',
        data: promotion.toPayload(),
      );

      if (response.statusCode == 200) {
        return Promotion.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception('Failed to update promotion. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to update promotion: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Promotion> updatePromotionStatus(int id, String status) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/promotions/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Promotion.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception('Failed to update promotion status. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to update promotion status: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deletePromotion(int id) async {
    try {
      final response = await _dioClient.dio.delete('/api/v1/admin/promotions/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete promotion. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to delete promotion: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProviders() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/providers');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] as List);
      }
      throw Exception('Failed to load providers. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load providers: ${e.response?.data['messages'] ?? e.message}',
      );
    }
  }
}
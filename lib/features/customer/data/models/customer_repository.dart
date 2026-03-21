import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

import 'category_model.dart';
import 'promotion_model.dart';
import 'service_model.dart';

class CustomerRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Category>> getCategories() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/customer/categories');

      if (res.statusCode == 200) {
        final list = (res.data['data'] as List)
            .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        return list;
      }

      throw Exception('Failed to load categories. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load categories: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Service>> getServicesByCategory(int categoryId) async {
    try {
      final res = await _dioClient.dio.get(
        '/api/v1/customer/categories/$categoryId/services',
      );

      if (res.statusCode == 200) {
        final list = (res.data['data'] as List)
            .map((e) => Service.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        return list;
      }

      throw Exception('Failed to load services. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load services: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Service>> getAllServices() async {
    final categories = await getCategories();
    final all = <Service>[];

    for (final c in categories) {
      final services = await getServicesByCategory(c.id);
      all.addAll(services);
    }

    return all;
  }

  Future<List<CustomerPromotion>> getActivePromotions() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/promotions/active');

      if (res.statusCode == 200) {
        final data = (res.data['data'] as List<dynamic>? ?? const []);
        return data
            .map((e) => CustomerPromotion.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception('Failed to load promotions. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load promotions: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    required String serviceName,
    required String bookingType,
    DateTime? scheduledAt,
    required String address,
    required String note,
  }) async {
    try {
      final res = await _dioClient.dio.post(
        '/api/v1/customer/bookings',
        data: {
          'service_id': serviceId,
          'service_name': serviceName,
          'booking_type': bookingType,
          'scheduled_at': scheduledAt?.toIso8601String(),
          'address': address,
          'note': note,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Map<String, dynamic>.from(res.data['data'] ?? const {});
      }

      throw Exception('Failed to create booking. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to create booking: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
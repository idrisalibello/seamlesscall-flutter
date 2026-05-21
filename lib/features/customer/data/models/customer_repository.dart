import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

import 'category_model.dart';
import 'popular_service_model.dart';
import 'promotion_model.dart';
import 'service_model.dart';

class CustomerRepository {
  final DioClient _dioClient = DioClient();

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/customer/categories');
      if (res.statusCode == 200) {
        return (res.data['data'] as List)
            .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
            .toList();
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

  // ── Services ──────────────────────────────────────────────────────────────

  Future<List<Service>> getServicesByCategory(int categoryId) async {
    try {
      final res = await _dioClient.dio
          .get('/api/v1/customer/categories/$categoryId/services');
      if (res.statusCode == 200) {
        return (res.data['data'] as List)
            .map((e) => Service.fromMap(Map<String, dynamic>.from(e)))
            .toList();
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
      all.addAll(await getServicesByCategory(c.id));
    }
    return all;
  }

  /// Returns services ranked by bookings × 3 + avg_rating × 10 + views × 0.5.
  /// Used exclusively by the "Popular services" row on the home screen.
  Future<List<PopularService>> getPopularServices({int limit = 6}) async {
    try {
      final res = await _dioClient.dio.get(
        '/api/v1/customer/services/popular',
        queryParameters: {'limit': limit},
      );
      if (res.statusCode == 200) {
        final data = res.data['data'] as List? ?? [];
        return data
            .map((e) => PopularService.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception(
          'Failed to load popular services. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load popular services: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Increments view_count for a service.
  /// Fire-and-forget — caller should not await the result.
  Future<void> recordServiceView(int serviceId) async {
    try {
      await _dioClient.dio
          .post('/api/v1/customer/services/$serviceId/view');
    } catch (_) {
      // Silently ignore — view tracking is non-critical
    }
  }

  // ── Promotions ────────────────────────────────────────────────────────────

  Future<List<CustomerPromotion>> getActivePromotions() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/promotions/active');
      if (res.statusCode == 200) {
        final data = (res.data['data'] as List<dynamic>? ?? const []);
        return data
            .map((e) =>
                CustomerPromotion.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception(
          'Failed to load promotions. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to load promotions: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Validates a promotion against a service and amount.
  ///
  /// Pass either [promotionId] (for card tap) or [code] (for coupon entry).
  /// Returns the full validation result including [discountApplied] and
  /// [finalAmount] so the booking summary can display the discounted price.
  Future<Map<String, dynamic>> validatePromotion({
    int? promotionId,
    String? code,
    required int serviceId,
    required double amount,
  }) async {
    assert(promotionId != null || code != null,
        'Provide either promotionId or code');

    try {
      final body = <String, dynamic>{
        'service_id': serviceId,
        'amount': amount,
      };
      if (promotionId != null) body['promotion_id'] = promotionId;
      if (code != null) body['code'] = code.trim().toUpperCase();

      final res = await _dioClient.dio.post(
        '/api/v1/customer/promotions/validate',
        data: body,
      );

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(res.data);
      }
      throw Exception('Validation failed. Status: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        'Promotion validation error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

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
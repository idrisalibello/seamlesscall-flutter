import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

import 'category_model.dart';
import 'service_model.dart';

class CustomerRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Category>> getCategories() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/admin/categories');
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
        '/api/v1/admin/categories/$categoryId/services',
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

  /// There is no single backend endpoint for "all services" right now.
  /// We derive it by fetching services per category (then flatten).
  Future<List<Service>> getAllServices() async {
    final categories = await getCategories();
    final all = <Service>[];

    for (final c in categories) {
      final services = await getServicesByCategory(c.id);
      all.addAll(services);
    }

    return all;
  }
}

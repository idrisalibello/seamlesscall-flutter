import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class ReportsRepository {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getSummary({
    required String fromDate,
    required String toDate,
  }) {
    return _get(
      '/api/v1/admin/reports/summary',
      queryParameters: {'from_date': fromDate, 'to_date': toDate},
      fallbackMessage: 'Failed to load reports summary',
    );
  }

  Future<Map<String, dynamic>> getOperationsReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? status,
    int? categoryId,
    int? providerId,
    String? search,
  }) {
    return _get(
      '/api/v1/admin/reports/operations',
      queryParameters: {
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'status': status,
        'category_id': categoryId,
        'provider_id': providerId,
        'search': search,
      },
      fallbackMessage: 'Failed to load operations report',
    );
  }

  Future<Map<String, dynamic>> getProvidersReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? providerStatus,
    String? search,
  }) {
    return _get(
      '/api/v1/admin/reports/providers',
      queryParameters: {
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'provider_status': providerStatus,
        'search': search,
      },
      fallbackMessage: 'Failed to load provider report',
    );
  }

  Future<Map<String, dynamic>> getCustomersReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? search,
  }) {
    return _get(
      '/api/v1/admin/reports/customers',
      queryParameters: {
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'search': search,
      },
      fallbackMessage: 'Failed to load customer report',
    );
  }

  Future<Map<String, dynamic>> getFinanceReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? providerId,
    String? commissionStatus,
  }) {
    return _get(
      '/api/v1/admin/reports/finance',
      queryParameters: {
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'provider_id': providerId,
        'commission_status': commissionStatus,
      },
      fallbackMessage: 'Failed to load finance report',
    );
  }

  Future<Map<String, dynamic>> getPromotionsReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? status,
    String? promotionType,
  }) {
    return _get(
      '/api/v1/admin/reports/promotions',
      queryParameters: {
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'status': status,
        'promotion_type': promotionType,
      },
      fallbackMessage: 'Failed to load promotions report',
    );
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required Map<String, dynamic> queryParameters,
    required String fallbackMessage,
  }) async {
    try {
      final cleanParams = Map<String, dynamic>.from(queryParameters)
        ..removeWhere((key, value) => value == null || value == '');

      final response = await _dioClient.dio.get(
        path,
        queryParameters: cleanParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception('$fallbackMessage. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        '$fallbackMessage: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

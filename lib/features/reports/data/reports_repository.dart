import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class ReportsRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getOverview({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/api/v1/admin/reports/overview',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> getOperations({
    required String from,
    required String to,
    String? status,
  }) async {
    final qp = <String, dynamic>{'from': from, 'to': to};
    if (status != null && status.isNotEmpty && status != 'All') {
      qp['status'] = status;
    }

    final response = await _dio.get(
      '/api/v1/admin/reports/operations',
      queryParameters: qp,
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> getProviders({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/api/v1/admin/reports/providers',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> getCustomers({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/api/v1/admin/reports/customers',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> getFinance({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/api/v1/admin/reports/finance',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<Map<String, dynamic>> getPromotions({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      '/api/v1/admin/reports/promotions',
      queryParameters: {'from': from, 'to': to},
    );
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }
}
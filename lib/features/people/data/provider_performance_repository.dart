import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/provider_performance_models.dart'; // Assuming this exists with fromJson

class ProviderPerformanceRepository {
  final Dio _dio = DioClient().dio;

  // Helper to build query parameters
  Map<String, dynamic> _buildQueryParams(String? from, String? to) {
    final Map<String, dynamic> params = {};
    if (from != null && from.isNotEmpty) {
      params['from'] = from;
    }
    if (to != null && to.isNotEmpty) {
      params['to'] = to;
    }
    return params;
  }

  // Helper for pagination parameters
  Map<String, dynamic> _buildPaginationParams(int? page, int? limit) {
    final Map<String, dynamic> params = {};
    if (page != null) {
      params['page'] = page;
    }
    if (limit != null) {
      params['limit'] = limit;
    }
    return params;
  }

  Future<List<ProviderPerformanceSummary>> fetchProviderPerformanceList({
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = _buildQueryParams(from, to)
        ..addAll(_buildPaginationParams(page, limit));

      final response = await _dio.get(
        '/api/v1/admin/providers/performance',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data']; // Assume {"data": [...]}
      return data
          .map((json) => ProviderPerformanceSummary.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in fetchProviderPerformanceList: $e');
      rethrow;
    }
  }

  Future<ProviderPerformanceDetail> fetchProviderPerformanceDetail(
    int providerId, {
    String? from,
    String? to,
    String? bucket,
  }) async {
    try {
      final queryParams = _buildQueryParams(from, to);
      if (bucket != null && bucket.isNotEmpty) {
        queryParams['bucket'] = bucket;
      }

      final response = await _dio.get(
        '/api/v1/admin/providers/$providerId/performance',
        queryParameters: queryParams,
      );
      // Backend returns directly the object, not wrapped in "data" for detail
      return ProviderPerformanceDetail.fromJson(response.data); 
    } catch (e) {
      print('Error in fetchProviderPerformanceDetail: $e');
      rethrow;
    }
  }

  Future<ProviderRatingsDistribution> fetchProviderRatings(
    int providerId, {
    String? from,
    String? to,
  }) async {
    try {
      final queryParams = _buildQueryParams(from, to);

      final response = await _dio.get(
        '/api/v1/admin/providers/$providerId/ratings',
        queryParameters: queryParams,
      );
      // Backend returns directly the object, not wrapped in "data" for ratings
      return ProviderRatingsDistribution.fromJson(response.data);
    } catch (e) {
      print('Error in fetchProviderRatings: $e');
      rethrow;
    }
  }

  Future<List<ProviderDispute>> fetchProviderDisputes(
    int providerId, {
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = _buildQueryParams(from, to)
        ..addAll(_buildPaginationParams(page, limit));

      final response = await _dio.get(
        '/api/v1/admin/providers/$providerId/disputes',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data']; // Assume {"data": [...]}
      return data.map((json) => ProviderDispute.fromJson(json)).toList();
    } catch (e) {
      print('Error in fetchProviderDisputes: $e');
      rethrow;
    }
  }
}

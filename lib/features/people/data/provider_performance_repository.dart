import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/provider_performance_models.dart';

class ProviderPerformanceRepository {
  final Dio _dio = DioClient().dio;

  // Helper to build query parameters
  Map<String, dynamic> _buildQueryParams(String? from, String? to) {
    final Map<String, dynamic> params = {};
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;
    return params;
  }

  // Helper for pagination parameters
  Map<String, dynamic> _buildPaginationParams(int? page, int? limit) {
    final Map<String, dynamic> params = {};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    return params;
  }

  // --- JSON coercion helpers (fix LinkedMap<dynamic,dynamic> on web) ---
  Map<String, dynamic> _asStringMap(dynamic v) =>
      Map<String, dynamic>.from(v as Map);

  List<Map<String, dynamic>> _asStringMapList(dynamic v) =>
      (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  // Accept both shapes:
  // 1) { data: ... }
  // 2) ...
  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
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

      final raw = _unwrapData(response.data);
      final list = _asStringMapList(raw);

      return list
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
      if (bucket != null && bucket.isNotEmpty) queryParams['bucket'] = bucket;

      final response = await _dio.get(
        '/api/v1/admin/providers/$providerId/performance',
        queryParameters: queryParams,
      );

      final raw = _unwrapData(response.data);
      final json = _asStringMap(raw);

      return ProviderPerformanceDetail.fromJson(json);
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

      final dynamic raw =
          (response.data is Map && (response.data as Map).containsKey('data'))
          ? (response.data as Map)['data']
          : response.data;

      final Map<String, dynamic> json = Map<String, dynamic>.from(raw as Map);
      return ProviderRatingsDistribution.fromJson(json);
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

      final raw = _unwrapData(response.data);
      final list = _asStringMapList(raw);

      return list.map((json) => ProviderDispute.fromJson(json)).toList();
    } catch (e) {
      print('Error in fetchProviderDisputes: $e');
      rethrow;
    }
  }
}

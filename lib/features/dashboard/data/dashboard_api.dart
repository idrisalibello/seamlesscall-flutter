import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class DashboardApi {
  final DioClient _dioClient;

  DashboardApi({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getStats() async {
    log('[DashboardApi] Fetching dashboard stats...');
    try {
      final response = await _dioClient.dio.get('/dashboard/stats');
      log('[DashboardApi] Stats response received: ${response.data}');
      return response.data['data'] as Map<String, dynamic>;
    } on DioError catch (e) {
      log('[DashboardApi] Error fetching stats: $e');
      rethrow;
    } catch (e) {
      log('[DashboardApi] An unexpected error occurred: $e');
      rethrow;
    }
  }
}

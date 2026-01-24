import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/operations/domain/job.dart';

class OperationsRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Job>> getActiveJobs(String role) async {
    final endpoint = role == 'Admin'
        ? '/api/v1/operations/admin/jobs'
        : '/api/v1/operations/provider/jobs';
    try {
      final response = await _dio.get(endpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Job.fromJson(json)).toList();
    } on DioException {
      // Re-throw the DioException to be handled by the UI layer.
      rethrow;
    }
  }

  Future<Job> getJobDetails(String role, int jobId) async {
    final endpoint = role == 'Admin'
        ? '/api/v1/operations/admin/jobs/$jobId'
        : '/api/v1/operations/provider/jobs/$jobId';
    try {
      final response = await _dio.get(endpoint);
      return Job.fromJson(response.data['data']);
    } on DioException {
      // Re-throw the DioException to be handled by the UI layer.
      rethrow;
    }
  }

  Future<bool> updateJobStatus(int jobId, String status) async {
    try {
      await _dio.put(
        '/api/v1/operations/provider/jobs/$jobId/status',
        data: {'status': status},
      );
      return true;
    } on DioException {
      // Re-throw the DioException to be handled by the UI layer.
      rethrow;
    }
  }





  Future<bool> assignJob(int jobId, int providerId) async {
    try {
      await _dio.post(
        '/api/v1/operations/admin/jobs/$jobId/assign',
        data: {'provider_id': providerId},
      );
      return true;
    } on DioException {
      // Re-throw the DioException to be handled by the UI layer.
      rethrow;
    }
  }

  Future<List<Job>> getAdminPendingJobs() async {
    try {
      final response = await _dio.get('/api/v1/operations/admin/jobs/pending');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Job.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableProviders() async {
    try {
      final response = await _dio.get('/api/v1/operations/admin/providers/available');
      final List<dynamic> data = response.data['data'];
      // Assuming the API returns a list of maps, e.g., [{'id': 1, 'name': 'Provider A'}]
      return data.map((json) => json as Map<String, dynamic>).toList();
    } on DioException {
      rethrow;
    }
  }
}

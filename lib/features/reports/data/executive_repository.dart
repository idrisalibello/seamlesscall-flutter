import '../../../core/network/dio_client.dart';

class ExecutiveRepository {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> getExecutive() async {
    final res = await _client.dio.get('/api/v1/admin/reports/executive');
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<Map<String, dynamic>> getOperationsSummary() async {
    final res = await _client.dio.get('/api/v1/admin/reports/operations/summary');
    return Map<String, dynamic>.from(res.data['data']);
  }
}
import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class FinanceRepository {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getEarningsOverview({
    required String fromDate, // YYYY-MM-DD
    required String toDate, // YYYY-MM-DD
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/earnings',
        queryParameters: {
          'from_date': fromDate,
          'to_date': toDate,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load earnings overview. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load earnings overview: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

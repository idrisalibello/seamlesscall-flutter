import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';
import 'package:seamlesscall/features/people/data/models/payout_entry.dart';

class FinanceRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Provider>> getProviders() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/providers');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Provider.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception(
        'Failed to load providers. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load providers: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

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

  /// Finance -> Provider Payouts (global, filter-driven)
  ///
  /// GET /api/v1/admin/finance/payouts
  /// Required: from_date, to_date
  /// Optional: provider_id, status
  Future<Map<String, dynamic>> getFinancePayouts({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? providerId,
    String? status,
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'provider_id': providerId,
        'status': status,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/payouts',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load payouts. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load payouts: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/payouts/summary
  Future<Map<String, dynamic>> getFinancePayoutsSummary({
    required String fromDate,
    required String toDate,
    int? providerId,
    String? status,
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'provider_id': providerId,
        'status': status,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/payouts/summary',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load payout summary. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load payout summary: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PayoutEntry> markPayoutPaid({
    required int payoutId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/finance/payouts/$payoutId/mark-paid',
        data: {
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
        },
      );

      if (response.statusCode == 200) {
        return PayoutEntry.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception(
        'Failed to mark payout paid. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to mark payout paid: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PayoutEntry> markPayoutFailed({
    required int payoutId,
    required String reason,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/finance/payouts/$payoutId/mark-failed',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return PayoutEntry.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }

      throw Exception(
        'Failed to mark payout failed. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to mark payout failed: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

// import 'package:dio/dio.dart';
// import 'package:seamlesscall/core/network/dio_client.dart';

// class FinanceRepository {
//   final DioClient _dioClient = DioClient();

//   Future<Map<String, dynamic>> getEarningsOverview({
//     required String fromDate, // YYYY-MM-DD
//     required String toDate, // YYYY-MM-DD
//     required int page,
//     required int pageSize,
//   }) async {
//     try {
//       final response = await _dioClient.dio.get(
//         '/api/v1/admin/finance/earnings',
//         queryParameters: {
//           'from_date': fromDate,
//           'to_date': toDate,
//           'page': page,
//           'page_size': pageSize,
//         },
//       );

//       if (response.statusCode == 200) {
//         return Map<String, dynamic>.from(response.data['data'] as Map);
//       }

//       throw Exception(
//         'Failed to load earnings overview. Status code: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       throw Exception(
//         'Failed to load earnings overview: ${e.response?.data['messages'] ?? e.message}',
//       );
//     } catch (e) {
//       throw Exception('An unexpected error occurred: $e');
//     }
//   }
// }

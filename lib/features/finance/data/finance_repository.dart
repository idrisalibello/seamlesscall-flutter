import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';
import 'package:seamlesscall/features/people/data/models/payout_entry.dart';

class FinanceRepository {
  final DioClient _dioClient = DioClient();

  /// GET /api/v1/admin/finance/commission-config
  Future<Map<String, dynamic>> getCommissionConfig() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/commission-config',
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw Exception(
        'Failed to load commission config. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load commission config: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// PATCH /api/v1/admin/finance/commission-config
  Future<Map<String, dynamic>> updateCommissionConfig({
    required double rate,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/finance/commission-config',
        data: {'rate': rate},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      throw Exception(
        'Failed to update commission config. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update commission config: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/commissions
  Future<Map<String, dynamic>> getPlatformCommissions({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? providerId,
    String? status, // confirmed|unconfirmed|null
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
        '/api/v1/admin/finance/commissions',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load platform commissions. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load platform commissions: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/commissions/summary
  Future<Map<String, dynamic>> getPlatformCommissionsSummary({
    required String fromDate,
    required String toDate,
    int? providerId,
    String? status, // confirmed|unconfirmed|null
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'provider_id': providerId,
        'status': status,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/commissions/summary',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load commission summary. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load commission summary: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// PATCH /api/v1/admin/finance/commissions/{earningId}/confirm
  Future<Map<String, dynamic>> confirmCommission({
    required int earningId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'api/v1/admin/finance/commissions/$earningId/confirm',
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to confirm commission. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to confirm commission: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

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

  /// GET /api/v1/admin/finance/refunds
  Future<Map<String, dynamic>> getFinanceRefunds({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? userId,
    String? status, // pending|approved|rejected|null
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'user_id': userId,
        'status': status,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/refunds',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load refunds. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load refunds: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/refunds/summary
  Future<Map<String, dynamic>> getFinanceRefundsSummary({
    required String fromDate,
    required String toDate,
    int? userId,
    String? status,
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'user_id': userId,
        'status': status,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/refunds/summary',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load refunds summary. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load refunds summary: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// PATCH /api/v1/admin/finance/refunds/{id}/status
  Future<Map<String, dynamic>> updateRefundStatus({
    required int refundId,
    required String status, // approved|rejected
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/finance/refunds/$refundId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to update refund status. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update refund status: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/disputes
  Future<Map<String, dynamic>> getFinanceDisputes({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? providerId,
    String? status, // pending|resolved|dismissed|null
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
        '/api/v1/admin/finance/disputes',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load disputes. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load disputes: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/disputes/summary
  Future<Map<String, dynamic>> getFinanceDisputesSummary({
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
        '/api/v1/admin/finance/disputes/summary',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load disputes summary. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load disputes summary: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// PATCH /api/v1/admin/finance/disputes/{id}/status
  Future<Map<String, dynamic>> updateDisputeStatus({
    required int disputeId,
    required String status, // resolved|dismissed
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/v1/admin/finance/disputes/$disputeId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to update dispute status. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update dispute status: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/ledger
  Future<Map<String, dynamic>> getFinanceLedger({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? userId,
    String? transactionType,
    String? reference,
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
        'page_size': pageSize,
        'user_id': userId,
        'transaction_type': transactionType,
        'reference': reference,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/ledger',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load ledger. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load ledger: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// GET /api/v1/admin/finance/ledger/summary
  Future<Map<String, dynamic>> getFinanceLedgerSummary({
    required String fromDate,
    required String toDate,
    int? userId,
    String? transactionType,
    String? reference,
  }) async {
    try {
      final qp = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
        'user_id': userId,
        'transaction_type': transactionType,
        'reference': reference,
      }..removeWhere((k, v) => v == null || v == '');

      final response = await _dioClient.dio.get(
        '/api/v1/admin/finance/ledger/summary',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception(
        'Failed to load ledger summary. Status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to load ledger summary: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

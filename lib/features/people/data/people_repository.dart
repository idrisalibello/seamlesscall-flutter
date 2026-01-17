// lib/features/people/data/people_repository.dart
import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/people/data/models/customer_model.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart'; // Added
import 'package:seamlesscall/features/people/data/models/ledger_entry.dart';
import 'package:seamlesscall/features/people/data/models/refund.dart';
import 'package:seamlesscall/features/people/data/models/activity_log_entry.dart';
import 'package:seamlesscall/features/people/data/models/earnings_entry.dart'; // Added
import 'package:seamlesscall/features/people/data/models/payout_entry.dart';   // Added

class PeopleRepository { // Renamed from CustomerRepository
  final DioClient _dioClient = DioClient();

  // --- Customer Specific Methods ---

  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/customers');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Customer.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load customers. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load customers: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Customer> getCustomerDetails(int customerId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/users/$customerId');
      if (response.statusCode == 200) {
        return Customer.fromMap(response.data['data']);
      } else {
        throw Exception(
            'Failed to load customer details. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load customer details: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Provider Specific Methods ---

  Future<List<Provider>> getProviders() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/providers');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Provider.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load providers. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load providers: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Provider> getProviderDetails(int providerId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/users/$providerId');
      if (response.statusCode == 200) {
        return Provider.fromMap(response.data['data']);
      } else {
        throw Exception(
            'Failed to load provider details. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load provider details: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<EarningsEntry>> getProviderEarnings(int providerId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/providers/$providerId/earnings');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => EarningsEntry.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load provider earnings. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load provider earnings: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<PayoutEntry>> getProviderPayouts(int providerId) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/providers/$providerId/payouts');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => PayoutEntry.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load provider payouts. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load provider payouts: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Generic User Data Methods (Ledger, Refunds, Activity) ---

  Future<List<LedgerEntry>> getUserLedger(int userId) async { // Renamed from getCustomerLedger
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/users/$userId/ledger');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => LedgerEntry.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load user ledger. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load user ledger: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Refund>> getUserRefunds(int userId) async { // Renamed from getCustomerRefunds
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/users/$userId/refunds');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => Refund.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load user refunds. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load user refunds: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<ActivityLogEntry>> getUserActivityLog(int userId) async { // Renamed from getCustomerActivityLog
    try {
      final response = await _dioClient.dio.get('/api/v1/admin/users/$userId/activity');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((e) => ActivityLogEntry.fromMap(e))
            .toList();
      } else {
        throw Exception(
            'Failed to load user activity log. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load user activity log: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateRefundStatus(int refundId, String status) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/admin/refunds/$refundId/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        // Successfully updated
      } else {
        throw Exception(
            'Failed to update refund status. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to update refund status: ${e.response?.data['messages'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Stubs for actions (now generic for any user)
  Future<void> messageUser(int userId, String message) async { // Renamed from messageCustomer
    // Implement API call to send message
    print('Stub: Sending message to user $userId: $message');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // throw Exception('Message API not implemented yet.');
  }

  Future<void> escalateUser(int userId, String reason) async { // Renamed from escalateCustomer
    // Implement API call to escalate customer
    print('Stub: Escalating user $userId for reason: $reason');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // throw Exception('Escalate API not implemented yet.');
  }
}

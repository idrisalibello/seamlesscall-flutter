import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

import 'order_model.dart';

class CustomerOrdersRepository {
  final DioClient _dioClient = DioClient();

  Future<List<CustomerOrder>> getOrders() async {
    try {
      final res = await _dioClient.dio.get('/api/v1/customer/bookings');

      if (res.statusCode != 200) {
        throw Exception('Failed to load orders. Status: ${res.statusCode}');
      }

      final rows = (res.data['data'] as List<dynamic>? ?? const []);

      return rows
          .map((row) => _mapJobToOrder(Map<String, dynamic>.from(row)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to load orders: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(String jobId) async {
    try {
      final res = await _dioClient.dio.get('/api/v1/customer/bookings/$jobId');

      if (res.statusCode != 200) {
        throw Exception(
          'Failed to load job details. Status: ${res.statusCode}',
        );
      }

      return Map<String, dynamic>.from(res.data['data'] ?? const {});
    } on DioException catch (e) {
      throw Exception(
        'Failed to load job details: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> initializeInspectionPayment(String jobId) async {
    try {
      final res = await _dioClient.dio.post(
        '/api/v1/customer/payments/initialize',
        data: {'job_id': int.parse(jobId)},
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(
          'Failed to initialize payment. Status: ${res.statusCode}',
        );
      }

      return Map<String, dynamic>.from(res.data['data'] ?? const {});
    } on DioException catch (e) {
      throw Exception(
        'Failed to initialize payment: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      final res = await _dioClient.dio.get(
        '/api/v1/customer/payments/verify/$reference',
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to verify payment. Status: ${res.statusCode}');
      }

      return Map<String, dynamic>.from(res.data['data'] ?? const {});
    } on DioException catch (e) {
      throw Exception(
        'Failed to verify payment: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  CustomerOrder _mapJobToOrder(Map<String, dynamic> row) {
    final description = _decodeDescription(row['description']);
    final paymentSummary = row['payment_summary'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(row['payment_summary'])
        : <String, dynamic>{};

    final status = (row['status'] ?? '').toString().toLowerCase();
    final providerId = row['provider_id'];
    final scheduledTime = (row['scheduled_time'] ?? '').toString();
    final updatedAtRaw =
        (row['updated_at'] ?? row['created_at'] ?? '').toString();

    final subtitle = (description['address'] ?? '').toString().trim().isNotEmpty
        ? (description['address'] ?? '').toString().trim()
        : (scheduledTime.isNotEmpty ? scheduledTime : 'Service request');

    final paymentStatus = (paymentSummary['status'] ?? '').toString().toLowerCase();

    final ({OrderStage stage, PaymentState payment, String amountText}) mapped =
        _mapStatus(
          status: status,
          paymentStatus: paymentStatus,
          providerAssigned: providerId != null,
          amount: (paymentSummary['amount'] ?? 0).toString(),
          currency: (paymentSummary['currency'] ?? 'NGN').toString(),
        );

    return CustomerOrder(
      orderId: 'SC-${row['id']}',
      jobId: '${row['id']}',
      serviceName: (row['title'] ?? 'Service Request').toString(),
      subtitle: subtitle,
      stage: mapped.stage,
      payment: mapped.payment,
      amountText: mapped.amountText,
      updatedAt: _formatUpdatedAt(updatedAtRaw),
    );
  }

  Map<String, dynamic> _decodeDescription(dynamic value) {
    if (value == null) return const {};

    if (value is Map<String, dynamic>) return value;

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
    }

    return const {};
  }

  ({OrderStage stage, PaymentState payment, String amountText}) _mapStatus({
    required String status,
    required String paymentStatus,
    required bool providerAssigned,
    required String amount,
    required String currency,
  }) {
    final amountText = _formatAmount(amount, currency);

    if (status == 'completed') {
      return (
        stage: OrderStage.completed,
        payment: PaymentState.paid,
        amountText: 'Completed',
      );
    }

    if (status == 'cancelled') {
      return (
        stage: OrderStage.cancelled,
        payment: PaymentState.failed,
        amountText: 'Cancelled',
      );
    }

    if (paymentStatus == 'success') {
      if (status == 'active') {
        return (
          stage: providerAssigned ? OrderStage.enRoute : OrderStage.inProgress,
          payment: PaymentState.inspectionPaid,
          amountText: '$amountText paid • Inspection cleared',
        );
      }

      return (
        stage: OrderStage.requested,
        payment: PaymentState.inspectionPaid,
        amountText: '$amountText paid • Awaiting dispatch',
      );
    }

    if (paymentStatus == 'failed' || paymentStatus == 'abandoned' || paymentStatus == 'reversed') {
      return (
        stage: OrderStage.requested,
        payment: PaymentState.failed,
        amountText: '$amountText failed • Retry needed',
      );
    }

    if (status == 'active') {
      return (
        stage: providerAssigned ? OrderStage.enRoute : OrderStage.inProgress,
        payment: PaymentState.inspectionPaid,
        amountText: 'Inspection paid • In progress',
      );
    }

    if (status == 'scheduled') {
      return (
        stage: OrderStage.inspectionDue,
        payment: PaymentState.inspectionDue,
        amountText: '$amountText • Scheduled • Inspection pending',
      );
    }

    return (
      stage: OrderStage.requested,
      payment: PaymentState.inspectionDue,
      amountText: '$amountText • Inspection pending',
    );
  }

  String _formatAmount(String rawAmount, String currency) {
    final amount = double.tryParse(rawAmount) ?? 0;
    final symbol = currency.toUpperCase() == 'NGN' ? '₦' : '${currency.toUpperCase()} ';
    if (amount == amount.roundToDouble()) {
      return '$symbol${amount.toInt()}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String _formatUpdatedAt(String raw) {
    if (raw.trim().isEmpty) return 'Recently';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final two = (int v) => v.toString().padLeft(2, '0');
    return '${parsed.year}-${two(parsed.month)}-${two(parsed.day)} • ${two(parsed.hour)}:${two(parsed.minute)}';
  }
}
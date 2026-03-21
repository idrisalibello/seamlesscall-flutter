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

  CustomerOrder _mapJobToOrder(Map<String, dynamic> row) {
    final description = _decodeDescription(row['description']);
    final status = (row['status'] ?? '').toString().toLowerCase();
    final providerId = row['provider_id'];
    final scheduledTime = (row['scheduled_time'] ?? '').toString();
    final updatedAtRaw =
        (row['updated_at'] ?? row['created_at'] ?? '').toString();

    final subtitle = (description['address'] ?? '').toString().trim().isNotEmpty
        ? (description['address'] ?? '').toString().trim()
        : (scheduledTime.isNotEmpty ? scheduledTime : 'Service request');

    final ({OrderStage stage, PaymentState payment, String amountText}) mapped =
        _mapStatus(
          status: status,
          providerAssigned: providerId != null,
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
    required bool providerAssigned,
  }) {
    switch (status) {
      case 'completed':
        return (
          stage: OrderStage.completed,
          payment: PaymentState.paid,
          amountText: 'Completed',
        );
      case 'cancelled':
        return (
          stage: OrderStage.cancelled,
          payment: PaymentState.failed,
          amountText: 'Cancelled',
        );
      case 'active':
        return (
          stage: providerAssigned ? OrderStage.enRoute : OrderStage.inProgress,
          payment: PaymentState.inspectionPaid,
          amountText: providerAssigned
              ? 'Inspection paid • Technician assigned'
              : 'Inspection paid • In progress',
        );
      case 'scheduled':
        return (
          stage: OrderStage.inspectionDue,
          payment: PaymentState.inspectionDue,
          amountText: 'Scheduled • Inspection pending',
        );
      case 'escalated':
        return (
          stage: OrderStage.inProgress,
          payment: PaymentState.executionPending,
          amountText: 'Escalated for review',
        );
      case 'pending':
      default:
        return (
          stage: OrderStage.requested,
          payment: PaymentState.inspectionDue,
          amountText: 'Inspection pending',
        );
    }
  }

  String _formatUpdatedAt(String raw) {
    if (raw.trim().isEmpty) return 'Recently';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final two = (int v) => v.toString().padLeft(2, '0');
    return '${parsed.year}-${two(parsed.month)}-${two(parsed.day)} • ${two(parsed.hour)}:${two(parsed.minute)}';
  }
}
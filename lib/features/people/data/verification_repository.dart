import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// Basic data model for a verification case
class VerificationCase {
  final int id;
  final int providerId;
  final String status;
  final String? decisionReason;
  final String? escalationReason;
  final int? decidedBy;
  final DateTime? decidedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String? providerName;
  final String? providerPhone;
  final String? providerEmail;

  VerificationCase({
    required this.id,
    required this.providerId,
    required this.status,
    this.decisionReason,
    this.escalationReason,
    this.decidedBy,
    this.decidedAt,
    required this.createdAt,
    this.updatedAt,
    this.providerName,
    this.providerPhone,
    this.providerEmail,
  });

  factory VerificationCase.fromJson(Map<String, dynamic> json) {
    return VerificationCase(
      id: int.parse(json['id'].toString()),
      providerId: int.parse(json['provider_id'].toString()),
      status: json['status'],
      decisionReason: json['decision_reason'],
      escalationReason: json['escalation_reason'],
      decidedBy: json['decided_by'],
      decidedAt: json['decided_at'] != null ? DateTime.parse(json['decided_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      providerName: json['provider_name'],
      providerPhone: json['provider_phone'],
      providerEmail: json['provider_email'],
    );
  }
}


class VerificationRepository {
  final Dio _dio = DioClient().dio;

  Future<List<VerificationCase>> getVerificationQueue() async {
    try {
      final response = await _dio.get('/api/v1/admin/verification-queue');
      final data = response.data as List;
      return data.map((item) => VerificationCase.fromJson(item)).toList();
    } catch (e) {
      // TODO: Handle error properly
      print(e);
      rethrow;
    }
  }

  Future<VerificationCase> getVerificationCaseDetail(int caseId) async {
    try {
      final response = await _dio.get('/api/v1/admin/verification-queue/$caseId');
      return VerificationCase.fromJson(response.data);
    } catch (e) {
      // TODO: Handle error properly
      print(e);
      rethrow;
    }
  }

  Future<void> approveVerification(int caseId) async {
    try {
      await _dio.post('/api/v1/admin/verification-queue/$caseId/approve');
    } catch (e) {
      // TODO: Handle error properly
      print(e);
      rethrow;
    }
  }

  Future<void> rejectVerification(int caseId, String reason) async {
    try {
      await _dio.post(
        '/api/v1/admin/verification-queue/$caseId/reject',
        data: {'reason': reason},
      );
    } catch (e) {
      // TODO: Handle error properly
      print(e);
      rethrow;
    }
  }

  Future<void> escalateVerification(int caseId, String reason) async {
    try {
      await _dio.post(
        '/api/v1/admin/verification-queue/$caseId/escalate',
        data: {'reason': reason},
      );
    } catch (e) {
      // TODO: Handle error properly
      print(e);
      rethrow;
    }
  }
}

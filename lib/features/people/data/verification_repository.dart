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

  factory VerificationCase.fromJson(Map json) {
    int _reqInt(dynamic v, String field) {
      if (v == null) throw FormatException('Missing field: $field');
      final s = v.toString().trim();
      final n = int.tryParse(s);
      if (n == null) throw FormatException('Invalid int for $field: $s');
      return n;
    }

    int? _optInt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return int.tryParse(s);
    }

    DateTime? _optDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return null;
      return DateTime.tryParse(s);
    }

    final dynamic uid = json['user_id'] ?? json['provider_id'];

    return VerificationCase(
      id: _reqInt(json['id'], 'id'),
      providerId: _reqInt(uid, 'user_id/provider_id'),
      status: (json['kyc_status'] ?? '').toString(),

      decisionReason: json['decision_reason']?.toString(),
      escalationReason: json['escalation_reason']?.toString(),

      decidedBy: _optInt(json['decided_by']),
      decidedAt: _optDate(json['decided_at']),

      createdAt:
          _optDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _optDate(json['updated_at']),

      providerName: (json['provider_name'] ?? json['name'])?.toString(),
      providerPhone: (json['provider_phone'] ?? json['phone'])?.toString(),
      providerEmail: (json['provider_email'] ?? json['email'])?.toString(),
    );
  }
}

class VerificationRepository {
  final Dio _dio = DioClient().dio;

  Future<List<VerificationCase>> getVerificationQueue() async {
    try {
      final response = await _dio.get('/api/v1/admin/verification-queue');
      print('getVerificationQueue Response: ${response.data}');
      final data = response.data as List;
      return data.map((item) => VerificationCase.fromJson(item)).toList();
    } catch (e) {
      // TODO: Handle error properly
      print('Error in getVerificationQueue: $e');
      rethrow;
    }
  }

  Future<VerificationCase> getVerificationCaseDetail(int caseId) async {
    try {
      final response = await _dio.get(
        '/api/v1/admin/verification-queue/$caseId',
      );
      print('getVerificationCaseDetail Response: ${response.data}');
      return VerificationCase.fromJson(response.data);
    } catch (e) {
      // TODO: Handle error properly
      print('Error in getVerificationCaseDetail: $e');
      rethrow;
    }
  }

  Future<void> approveVerification(int caseId) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/verification-queue/$caseId/approve',
      );
      print('approveVerification Response: ${response.data}');
    } catch (e) {
      // TODO: Handle error properly
      print('Error in approveVerification: $e');
      rethrow;
    }
  }

  Future<void> rejectVerification(int caseId, String reason) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/verification-queue/$caseId/reject',
        data: {'reason': reason},
      );
      print('rejectVerification Response: ${response.data}');
    } catch (e) {
      // TODO: Handle error properly
      print('Error in rejectVerification: $e');
      rethrow;
    }
  }

  Future<void> escalateVerification(int caseId, String reason) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/verification-queue/$caseId/escalate',
        data: {'reason': reason},
      );
      print('escalateVerification Response: ${response.data}');
    } catch (e) {
      // TODO: Handle error properly
      print('Error in escalateVerification: $e');
      rethrow;
    }
  }
}

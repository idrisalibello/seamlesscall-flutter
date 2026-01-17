// lib/features/people/data/models/refund.dart
class Refund {
  final int id;
  final int userId;
  final int? transactionId;
  final double amount;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String submittedAt;
  final int? processedBy;
  final String? processedAt;

  Refund({
    required this.id,
    required this.userId,
    this.transactionId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.processedBy,
    this.processedAt,
  });

  factory Refund.fromMap(Map<String, dynamic> json) {
    return Refund(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      transactionId: json['transaction_id'] != null ? int.parse(json['transaction_id'].toString()) : null,
      amount: double.parse(json['amount'].toString()),
      reason: json['reason'] as String,
      status: json['status'] as String,
      submittedAt: json['submitted_at'] as String,
      processedBy: json['processed_by'] != null ? int.parse(json['processed_by'].toString()) : null,
      processedAt: json['processed_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_id': transactionId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'submitted_at': submittedAt,
      'processed_by': processedBy,
      'processed_at': processedAt,
    };
  }
}
// lib/features/people/data/models/earnings_entry.dart
class EarningsEntry {
  final int id;
  final int providerId;
  final double amount;
  final String? description;
  final int? jobId;
  final String createdAt;

  EarningsEntry({
    required this.id,
    required this.providerId,
    required this.amount,
    this.description,
    this.jobId,
    required this.createdAt,
  });

  factory EarningsEntry.fromMap(Map<String, dynamic> json) {
    return EarningsEntry(
      id: int.parse(json['id'].toString()),
      providerId: int.parse(json['provider_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      description: json['description'] as String?,
      jobId: json['job_id'] != null ? int.parse(json['job_id'].toString()) : null,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'amount': amount,
      'description': description,
      'job_id': jobId,
      'created_at': createdAt,
    };
  }
}
// lib/features/people/data/models/payout_entry.dart
class PayoutEntry {
  final int id;
  final int providerId;
  final double amount;
  final String status; // 'pending', 'processed', 'failed'
  final String? paymentMethod;
  final String? transactionId;
  final String requestedAt;
  final String? processedAt;

  PayoutEntry({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    required this.requestedAt,
    this.processedAt,
  });

  factory PayoutEntry.fromMap(Map<String, dynamic> json) {
    return PayoutEntry(
      id: int.parse(json['id'].toString()),
      providerId: int.parse(json['provider_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      requestedAt: json['requested_at'] as String,
      processedAt: json['processed_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'requested_at': requestedAt,
      'processed_at': processedAt,
    };
  }
}
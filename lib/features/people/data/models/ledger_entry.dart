// lib/features/people/data/models/ledger_entry.dart
class LedgerEntry {
  final int id;
  final int userId;
  final String transactionType;
  final double amount;
  final String? description;
  final String? reference;
  final String createdAt;

  LedgerEntry({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    this.description,
    this.reference,
    required this.createdAt,
  });

  factory LedgerEntry.fromMap(Map<String, dynamic> json) {
    return LedgerEntry(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      transactionType: json['transaction_type'] as String,
      amount: double.parse(json['amount'].toString()),
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_type': transactionType,
      'amount': amount,
      'description': description,
      'reference': reference,
      'created_at': createdAt,
    };
  }
}
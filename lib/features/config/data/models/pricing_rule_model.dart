class PricingRule {
  final int id;
  final String? label;
  final String scope; // category|service
  final int? categoryId;
  final int? serviceId;
  final String chargeType; // flat|percent
  final double amount;
  final String status; // active|inactive
  final String? notes;

  // Joined fields (list/detail convenience)
  final String? categoryName;
  final String? serviceName;

  PricingRule({
    required this.id,
    required this.label,
    required this.scope,
    required this.categoryId,
    required this.serviceId,
    required this.chargeType,
    required this.amount,
    required this.status,
    required this.notes,
    required this.categoryName,
    required this.serviceName,
  });

  factory PricingRule.fromMap(Map<String, dynamic> m) {
    return PricingRule(
      id: (m['id'] ?? 0) is int
          ? (m['id'] as int)
          : int.tryParse('${m['id']}') ?? 0,
      label: m['label'] as String?,
      scope: (m['scope'] ?? 'category').toString(),
      categoryId: m['category_id'] == null
          ? null
          : (m['category_id'] is int
                ? m['category_id'] as int
                : int.tryParse('${m['category_id']}')),
      serviceId: m['service_id'] == null
          ? null
          : (m['service_id'] is int
                ? m['service_id'] as int
                : int.tryParse('${m['service_id']}')),
      chargeType: (m['charge_type'] ?? 'flat').toString(),
      amount: (m['amount'] is num)
          ? (m['amount'] as num).toDouble()
          : double.tryParse('${m['amount']}') ?? 0,
      status: (m['status'] ?? 'active').toString(),
      notes: m['notes'] as String?,
      categoryName: m['category_name'] as String?,
      serviceName: m['service_name'] as String?,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'label': label,
      'scope': scope,
      'category_id': categoryId,
      'service_id': serviceId,
      'charge_type': chargeType,
      'amount': amount,
      'status': status,
      'notes': notes,
    }..removeWhere((k, v) => v == null || v == '');
  }
}

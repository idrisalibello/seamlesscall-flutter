class PricingAdjustment {
  final int id;
  final int profileId;
  final String label;
  final String adjustmentType; // flat|percent
  final double value;
  final double maxAllowed;
  final String appliesPhase; // inspection|execution
  final int requiresClientApproval; // 0/1
  final String status; // active|inactive

  PricingAdjustment({
    required this.id,
    required this.profileId,
    required this.label,
    required this.adjustmentType,
    required this.value,
    required this.maxAllowed,
    required this.appliesPhase,
    required this.requiresClientApproval,
    required this.status,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  factory PricingAdjustment.fromMap(Map<String, dynamic> m) {
    return PricingAdjustment(
      id: _asInt(m['id']),
      profileId: _asInt(m['profile_id']),
      label: (m['label'] ?? '').toString(),
      adjustmentType: (m['adjustment_type'] ?? 'flat').toString(),
      value: _asDouble(m['value']),
      maxAllowed: _asDouble(m['max_allowed']),
      appliesPhase: (m['applies_phase'] ?? 'execution').toString(),
      requiresClientApproval: _asInt(m['requires_client_approval']),
      status: (m['status'] ?? 'active').toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'label': label,
      'adjustment_type': adjustmentType,
      'value': value,
      'max_allowed': maxAllowed,
      'applies_phase': appliesPhase,
      'requires_client_approval': requiresClientApproval,
      'status': status,
    }..removeWhere((k, v) => v == null);
  }
}

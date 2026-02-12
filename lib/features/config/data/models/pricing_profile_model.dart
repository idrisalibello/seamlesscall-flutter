class PricingProfile {
  final int id;
  final int serviceId;
  final String pricingBasis; // fixed|hourly|unit|quote_after_inspection
  final double inspectionFee;
  final double minimumJobFee;
  final double priceBandMin;
  final double priceBandMax;
  final String currency; // NGN
  final String status; // active|inactive
  final String? notesForClient;
  final String? notesForProvider;
  final int allowBandOverride; // 0/1
  final int maxOverridePercent;
  final int requireAdminReview; // 0/1
  final int autoFlagDisputeThreshold;

  // Bands can be per-job (default) or per-unit (scalable jobs). Stored as 0/1.
  final int bandIsPerUnit;
  final String? unitLabel;

  // Alert thresholds (guidance only; should not block pricing).
  final int warnVariancePercent;
  final int criticalVariancePercent;
  final int requireReasonOverCritical; // 0/1

  // Joined convenience
  final String? serviceName;
  final int? categoryId;
  final String? categoryName;

  PricingProfile({
    required this.id,
    required this.serviceId,
    required this.pricingBasis,
    required this.inspectionFee,
    required this.minimumJobFee,
    required this.priceBandMin,
    required this.priceBandMax,
    required this.currency,
    required this.status,
    required this.notesForClient,
    required this.notesForProvider,
    required this.allowBandOverride,
    required this.maxOverridePercent,
    required this.requireAdminReview,
    required this.autoFlagDisputeThreshold,
    required this.bandIsPerUnit,
    required this.unitLabel,
    required this.warnVariancePercent,
    required this.criticalVariancePercent,
    required this.requireReasonOverCritical,
    required this.serviceName,
    required this.categoryId,
    required this.categoryName,
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

  factory PricingProfile.fromMap(Map<String, dynamic> m) {
    return PricingProfile(
      id: _asInt(m['id']),
      serviceId: _asInt(m['service_id']),
      pricingBasis: (m['pricing_basis'] ?? 'quote_after_inspection').toString(),
      inspectionFee: _asDouble(m['inspection_fee']),
      minimumJobFee: _asDouble(m['minimum_job_fee']),
      priceBandMin: _asDouble(m['price_band_min']),
      priceBandMax: _asDouble(m['price_band_max']),
      currency: (m['currency'] ?? 'NGN').toString(),
      status: (m['status'] ?? 'active').toString(),
      notesForClient: m['notes_for_client']?.toString(),
      notesForProvider: m['notes_for_provider']?.toString(),
      allowBandOverride: _asInt(m['allow_band_override']),
      maxOverridePercent: _asInt(m['max_override_percent']),
      requireAdminReview: _asInt(m['require_admin_review']),
      autoFlagDisputeThreshold: _asInt(m['auto_flag_dispute_threshold']),
      bandIsPerUnit: _asInt(m['band_is_per_unit']),
      unitLabel: m['unit_label']?.toString(),
      warnVariancePercent: m['warn_variance_percent'] == null
          ? 25
          : _asInt(m['warn_variance_percent']),
      criticalVariancePercent: m['critical_variance_percent'] == null
          ? 60
          : _asInt(m['critical_variance_percent']),
      requireReasonOverCritical: m['require_reason_over_critical'] == null
          ? 1
          : _asInt(m['require_reason_over_critical']),
      serviceName: m['service_name']?.toString(),
      categoryId: m['category_id'] == null ? null : _asInt(m['category_id']),
      categoryName: m['category_name']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'service_id': serviceId,
      'pricing_basis': pricingBasis,
      'inspection_fee': inspectionFee,
      'minimum_job_fee': minimumJobFee,
      'price_band_min': priceBandMin,
      'price_band_max': priceBandMax,
      'currency': currency,
      'status': status,
      'notes_for_client': notesForClient,
      'notes_for_provider': notesForProvider,
      'allow_band_override': allowBandOverride,
      'max_override_percent': maxOverridePercent,
      'require_admin_review': requireAdminReview,
      'auto_flag_dispute_threshold': autoFlagDisputeThreshold,
      'band_is_per_unit': bandIsPerUnit,
      'unit_label': unitLabel,
      'warn_variance_percent': warnVariancePercent,
      'critical_variance_percent': criticalVariancePercent,
      'require_reason_over_critical': requireReasonOverCritical,
    }..removeWhere((k, v) => v == null);
  }
}

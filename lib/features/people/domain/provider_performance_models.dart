// provider_performance_models.dart
// Plain models: no freezed, no code generation.

class ProviderPerformanceSummary {
  final int providerId;
  final String providerName;
  final String status;
  final int totalJobs;
  final int completedJobs;
  final int cancelledJobs;
  final int escalationsCount;
  final double avgRating;
  final int disputesCount;

  ProviderPerformanceSummary({
    required this.providerId,
    required this.providerName,
    required this.status,
    required this.totalJobs,
    required this.completedJobs,
    required this.cancelledJobs,
    required this.escalationsCount,
    required this.avgRating,
    required this.disputesCount,
  });

  factory ProviderPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return ProviderPerformanceSummary(
      providerId: (json['provider_id'] ?? json['providerId']) as int,
      providerName:
          (json['provider_name'] ?? json['providerName'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      totalJobs: (json['total_jobs'] ?? 0) as int,
      completedJobs: (json['completed_jobs'] ?? 0) as int,
      cancelledJobs: (json['cancelled_jobs'] ?? 0) as int,
      escalationsCount: (json['escalations_count'] ?? 0) as int,
      avgRating: _toDouble(json['avg_rating']),
      disputesCount: (json['disputes_count'] ?? 0) as int,
    );
  }
}

class ProviderIdentity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String kycStatus;
  final String providerStatus;

  ProviderIdentity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.kycStatus,
    required this.providerStatus,
  });

  factory ProviderIdentity.fromJson(Map<String, dynamic> json) {
    return ProviderIdentity(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      kycStatus: (json['kyc_status'] ?? json['kycStatus'] ?? '') as String,
      providerStatus:
          (json['provider_status'] ?? json['providerStatus'] ?? '') as String,
    );
  }
}

class ProviderSummaryMetrics {
  final int totalJobs;
  final int completedJobs;
  final int cancelledJobs;
  final int escalationsCount;
  final double avgRating;
  final int disputesCount;

  ProviderSummaryMetrics({
    required this.totalJobs,
    required this.completedJobs,
    required this.cancelledJobs,
    required this.escalationsCount,
    required this.avgRating,
    required this.disputesCount,
  });

  factory ProviderSummaryMetrics.fromJson(Map<String, dynamic> json) {
    return ProviderSummaryMetrics(
      totalJobs: (json['total_jobs'] ?? 0) as int,
      completedJobs: (json['completed_jobs'] ?? 0) as int,
      cancelledJobs: (json['cancelled_jobs'] ?? 0) as int,
      escalationsCount: (json['escalations_count'] ?? 0) as int,
      avgRating: _toDouble(json['avg_rating']),
      disputesCount: (json['disputes_count'] ?? 0) as int,
    );
  }
}

class JobTrendBucket {
  final String start;
  final String end;
  final int assigned;
  final int completed;
  final int cancelled;
  final int escalated;

  JobTrendBucket({
    required this.start,
    required this.end,
    required this.assigned,
    required this.completed,
    required this.cancelled,
    required this.escalated,
  });

  factory JobTrendBucket.fromJson(Map<String, dynamic> json) {
    return JobTrendBucket(
      start: (json['start'] ?? '') as String,
      end: (json['end'] ?? '') as String,
      assigned: (json['assigned'] ?? 0) as int,
      completed: (json['completed'] ?? 0) as int,
      cancelled: (json['cancelled'] ?? 0) as int,
      escalated: (json['escalated'] ?? 0) as int,
    );
  }
}

class ProviderPerformanceDetail {
  final ProviderIdentity providerIdentity;
  final ProviderSummaryMetrics summaryMetrics;
  final List<JobTrendBucket> jobTrendSeries;

  ProviderPerformanceDetail({
    required this.providerIdentity,
    required this.summaryMetrics,
    required this.jobTrendSeries,
  });

  factory ProviderPerformanceDetail.fromJson(Map<String, dynamic> json) {
    final identityJson =
        (json['provider_identity'] ?? json['providerIdentity'] ?? {})
            as Map<String, dynamic>;
    final summaryJson =
        (json['summary_metrics'] ?? json['summaryMetrics'] ?? {})
            as Map<String, dynamic>;
    final seriesJson =
        (json['job_trend_series'] ?? json['jobTrendSeries'] ?? [])
            as List<dynamic>;

    return ProviderPerformanceDetail(
      providerIdentity: ProviderIdentity.fromJson(identityJson),
      summaryMetrics: ProviderSummaryMetrics.fromJson(summaryJson),
      jobTrendSeries: seriesJson
          .whereType<Map>()
          .map((e) => JobTrendBucket.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ProviderRating {
  final int id;
  final int jobId;
  final int providerId;
  final int customerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderRating({
    required this.id,
    required this.jobId,
    required this.providerId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderRating.fromJson(Map<String, dynamic> json) {
    return ProviderRating(
      id: (json['id'] ?? 0) as int,
      jobId: (json['job_id'] ?? 0) as int,
      providerId: (json['provider_id'] ?? 0) as int,
      customerId: (json['customer_id'] ?? 0) as int,
      rating: (json['rating'] ?? 0) as int,
      comment: json['comment'] as String?,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }
}

class ProviderRatingsDistribution {
  final double avgRating;
  final Map<String, int> distribution; // keys "1".."5"

  ProviderRatingsDistribution({
    required this.avgRating,
    required this.distribution,
  });

  factory ProviderRatingsDistribution.fromJson(Map<String, dynamic> json) {
    final dist = (json['distribution'] ?? {}) as Map<String, dynamic>;
    return ProviderRatingsDistribution(
      avgRating: _toDouble(json['avg_rating']),
      distribution: dist.map((k, v) => MapEntry(k.toString(), (v ?? 0) as int)),
    );
  }
}

class ProviderDispute {
  final int id;
  final int jobId;
  final int providerId;
  final int? raisedBy;
  final String status;
  final String reason;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderDispute({
    required this.id,
    required this.jobId,
    required this.providerId,
    this.raisedBy,
    required this.status,
    required this.reason,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderDispute.fromJson(Map<String, dynamic> json) {
    return ProviderDispute(
      id: (json['id'] ?? 0) as int,
      jobId: (json['job_id'] ?? 0) as int,
      providerId: (json['provider_id'] ?? 0) as int,
      raisedBy: json['raised_by'] as int?,
      status: (json['status'] ?? '') as String,
      reason: (json['reason'] ?? '') as String,
      resolvedAt: json['resolved_at'] == null
          ? null
          : _toDateTime(json['resolved_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  final s = v.toString();
  return double.tryParse(s) ?? 0.0;
}

DateTime _toDateTime(dynamic v) {
  if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (v is DateTime) return v;
  final s = v.toString();
  return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

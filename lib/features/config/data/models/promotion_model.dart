class Promotion {
  final int? id;
  final String title;
  final String? description;
  final String promotionType;
  final String discountType;
  final double discountValue;
  final String? code;
  final int? serviceId;
  final int? providerId;
  final int? categoryId;
  final String? startDate;
  final String? endDate;
  final int? usageLimit;
  final String status;

  final String? serviceName;
  final String? categoryName;
  final String? providerName;

  const Promotion({
    this.id,
    required this.title,
    this.description,
    required this.promotionType,
    required this.discountType,
    required this.discountValue,
    this.code,
    this.serviceId,
    this.providerId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.usageLimit,
    required this.status,
    this.serviceName,
    this.categoryName,
    this.providerName,
  });

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: _asInt(map['id']),
      title: (map['title'] ?? '').toString(),
      description: map['description']?.toString(),
      promotionType: (map['promotion_type'] ?? 'global').toString(),
      discountType: (map['discount_type'] ?? 'percent').toString(),
      discountValue: _asDouble(map['discount_value']),
      code: map['code']?.toString(),
      serviceId: _asInt(map['service_id']),
      providerId: _asInt(map['provider_id']),
      categoryId: _asInt(map['category_id']),
      startDate: map['start_date']?.toString(),
      endDate: map['end_date']?.toString(),
      usageLimit: _asInt(map['usage_limit']),
      status: (map['status'] ?? 'inactive').toString(),
      serviceName: map['service_name']?.toString(),
      categoryName: map['category_name']?.toString(),
      providerName: map['provider_name']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'description': description,
      'promotion_type': promotionType,
      'discount_type': discountType,
      'discount_value': discountValue,
      'code': code,
      'service_id': serviceId,
      'provider_id': providerId,
      'category_id': categoryId,
      'start_date': startDate,
      'end_date': endDate,
      'usage_limit': usageLimit,
      'status': status,
    };
  }

  Promotion copyWith({
    int? id,
    String? title,
    String? description,
    String? promotionType,
    String? discountType,
    double? discountValue,
    String? code,
    int? serviceId,
    int? providerId,
    int? categoryId,
    String? startDate,
    String? endDate,
    int? usageLimit,
    String? status,
    String? serviceName,
    String? categoryName,
    String? providerName,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      promotionType: promotionType ?? this.promotionType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      code: code ?? this.code,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      status: status ?? this.status,
      serviceName: serviceName ?? this.serviceName,
      categoryName: categoryName ?? this.categoryName,
      providerName: providerName ?? this.providerName,
    );
  }

  String get targetLabel {
    switch (promotionType) {
      case 'service':
        if (serviceName != null && serviceName!.isNotEmpty) {
          return serviceName!;
        }

        if (categoryName != null && categoryName!.isNotEmpty) {
          return '$categoryName (All services)';
        }

        return 'Service';

      case 'provider':
        return providerName ?? 'Provider';

      case 'coupon':
        return code ?? 'Coupon';

      case 'global':
        return 'All services';

      default:
        return 'Unknown';
    }
  }

  String get discountLabel {
    if (discountType == 'percent') {
      return '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 2)}% off';
    }
    return '₦${discountValue.toStringAsFixed(2)} off';
  }

  String get validityLabel {
    final s = startDate == null || startDate!.isEmpty
        ? 'Any time'
        : startDate!.split(' ').first;
    final e = endDate == null || endDate!.isEmpty
        ? 'Open-ended'
        : endDate!.split(' ').first;
    return '$s → $e';
  }
}

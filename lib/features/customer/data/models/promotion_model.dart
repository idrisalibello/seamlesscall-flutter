class CustomerPromotion {
  final int id;
  final String title;
  final String? description;
  final String promotionType;
  final String discountType;
  final double discountValue;
  final String? code;
  final int? categoryId;
  final int? serviceId;
  final int? providerId;
  final String? startDate;
  final String? endDate;
  final int? usageLimit;
  final String status;
  final String? categoryName;
  final String? serviceName;
  final String? providerName;
  final String? targetLabel;

  const CustomerPromotion({
    required this.id,
    required this.title,
    this.description,
    required this.promotionType,
    required this.discountType,
    required this.discountValue,
    this.code,
    this.categoryId,
    this.serviceId,
    this.providerId,
    this.startDate,
    this.endDate,
    this.usageLimit,
    required this.status,
    this.categoryName,
    this.serviceName,
    this.providerName,
    this.targetLabel,
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

  factory CustomerPromotion.fromMap(Map<String, dynamic> map) {
    return CustomerPromotion(
      id: _asInt(map['id']) ?? 0,
      title: (map['title'] ?? '').toString(),
      description: map['description']?.toString(),
      promotionType: (map['promotion_type'] ?? 'global').toString(),
      discountType: (map['discount_type'] ?? 'percent').toString(),
      discountValue: _asDouble(map['discount_value']),
      code: map['code']?.toString(),
      categoryId: _asInt(map['category_id']),
      serviceId: _asInt(map['service_id']),
      providerId: _asInt(map['provider_id']),
      startDate: map['start_date']?.toString(),
      endDate: map['end_date']?.toString(),
      usageLimit: _asInt(map['usage_limit']),
      status: (map['status'] ?? 'inactive').toString(),
      categoryName: map['category_name']?.toString(),
      serviceName: map['service_name']?.toString(),
      providerName: map['provider_name']?.toString(),
      targetLabel: map['target_label']?.toString(),
    );
  }

  String get discountLabel {
    if (discountType == 'percent') {
      return '${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 2)}% OFF';
    }
    return '₦${discountValue.toStringAsFixed(2)} OFF';
  }

  String get resolvedTargetLabel {
    if (targetLabel != null && targetLabel!.trim().isNotEmpty) {
      return targetLabel!;
    }

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
      default:
        return 'All services';
    }
  }

  String get validityLabel {
    final start = (startDate == null || startDate!.isEmpty)
        ? 'Now'
        : startDate!.split(' ').first;
    final end = (endDate == null || endDate!.isEmpty)
        ? 'Open'
        : endDate!.split(' ').first;
    return '$start → $end';
  }
}
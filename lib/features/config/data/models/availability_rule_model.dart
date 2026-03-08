class AvailabilityRule {
  final int id;
  final int categoryId;
  final String categoryName;
  final String state;
  final String lga;
  final String city;
  final List<String> availabilityDays;
  final String? availabilityTimeStart;
  final String? availabilityTimeEnd;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  AvailabilityRule({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.state,
    required this.lga,
    required this.city,
    required this.availabilityDays,
    required this.availabilityTimeStart,
    required this.availabilityTimeEnd,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static String _asString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  static List<String> _asStringList(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      return v
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory AvailabilityRule.fromMap(Map<String, dynamic> map) {
    return AvailabilityRule(
      id: _asInt(map['id']),
      categoryId: _asInt(map['category_id']),
      categoryName: _asString(map['category_name']),
      state: _asString(map['state']),
      lga: _asString(map['lga']),
      city: _asString(map['city']),
      availabilityDays: _asStringList(map['availability_days']),
      availabilityTimeStart: map['availability_time_start']?.toString(),
      availabilityTimeEnd: map['availability_time_end']?.toString(),
      status: _asString(map['status'], fallback: 'inactive'),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'category_id': categoryId,
      'state': state,
      'lga': lga,
      'city': city,
      'availability_days': availabilityDays,
      'availability_time_start': availabilityTimeStart,
      'availability_time_end': availabilityTimeEnd,
      'status': status,
    }..removeWhere((key, value) => value == null);
  }

  bool get isActive => status.toLowerCase() == 'active';

  String get locationSummary {
    final parts = [city, lga, state].where((e) => e.trim().isNotEmpty).toList();
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  String get daysSummary {
    if (availabilityDays.isEmpty) return 'All days';
    const labels = {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
    };
    return availabilityDays
        .map((d) => labels[d.toLowerCase()] ?? d)
        .join(', ');
  }

  String get timeSummary {
    final start = _displayTime(availabilityTimeStart);
    final end = _displayTime(availabilityTimeEnd);
    if (start == null && end == null) return 'No time window';
    if (start != null && end != null) return '$start - $end';
    return start ?? end ?? 'No time window';
  }

  static String? _displayTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
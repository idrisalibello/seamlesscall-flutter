class Coverage {
  final int id;
  final String name;
  final String region;
  final bool isActive;

  Coverage({
    required this.id,
    required this.name,
    required this.region,
    required this.isActive,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static String _asString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    if (v is String) return v;
    return v.toString();
  }

  static bool _asBool01(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      final t = v.trim().toLowerCase();
      if (t == '1' || t == 'true' || t == 'yes') return true;
      if (t == '0' || t == 'false' || t == 'no') return false;
    }
    return fallback;
  }

  factory Coverage.fromMap(Map<String, dynamic> map) {
    return Coverage(
      id: _asInt(map['id']),
      name: _asString(map['name']),
      region: _asString(map['region']),
      isActive: _asBool01(map['is_active'], fallback: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'region': region,
      'is_active': isActive ? 1 : 0,
    };
  }
}
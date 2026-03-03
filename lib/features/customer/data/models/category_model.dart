class Category {
  final int id;
  final String name;
  final String? description;
  final String? status;
  final int? serviceCount;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.serviceCount,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: _toInt(map['id']),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      status: map['status']?.toString(),
      serviceCount: map['service_count'] == null
          ? null
          : _toInt(map['service_count']),
    );
  }
}

class Service {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? status;

  const Service({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.status,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    final rawCategoryId = map['category_id'] ?? map['categoryId'];

    return Service(
      id: _toInt(map['id']),
      categoryId: _toInt(rawCategoryId),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      status: map['status']?.toString(),
    );
  }
}

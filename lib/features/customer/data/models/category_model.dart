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

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] as num).toInt(),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      status: map['status']?.toString(),
      serviceCount: map['service_count'] == null
          ? null
          : (map['service_count'] as num).toInt(),
    );
  }
}

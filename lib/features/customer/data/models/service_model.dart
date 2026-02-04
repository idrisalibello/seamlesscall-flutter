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

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: (map['id'] as num).toInt(),
      categoryId: (map['category_id'] as num).toInt(),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      status: map['status']?.toString(),
    );
  }
}

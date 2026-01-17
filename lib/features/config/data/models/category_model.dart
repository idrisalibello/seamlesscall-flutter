// lib/features/config/data/models/category_model.dart
class Category {
  final int id;
  final String name;
  final String? description;
  final String status; // 'active' or 'inactive'
  final String createdAt;
  final String updatedAt;
  int? serviceCount; // Optional: to be populated by the API

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.serviceCount,
  });

  factory Category.fromMap(Map<String, dynamic> json) {
    return Category(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      serviceCount: json['service_count'] != null ? int.parse(json['service_count'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'service_count': serviceCount,
    };
  }
}
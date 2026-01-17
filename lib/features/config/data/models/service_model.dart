// lib/features/config/data/models/service_model.dart
class Service {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String status; // 'active' or 'inactive'
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromMap(Map<String, dynamic> json) {
    return Service(
      id: int.parse(json['id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
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
    int id;
    int categoryId;
    String name;
    String? description;
    String status;
    String createdAt;
    String updatedAt;

    try {
      id = int.parse(json['id'].toString());
    } catch (e) {
      print('Service.fromMap Error: Failed to parse id. Raw: ${json['id']}. Error: $e');
      rethrow;
    }
    try {
      categoryId = int.parse(json['category_id'].toString());
    } catch (e) {
      print('Service.fromMap Error: Failed to parse category_id. Raw: ${json['category_id']}. Error: $e');
      rethrow;
    }
    try {
      name = json['name'] as String;
    } catch (e) {
      print('Service.fromMap Error: Failed to parse name. Raw: ${json['name']}. Error: $e');
      rethrow;
    }
    // description is nullable, so no need for strict casting error check
    description = json['description'] as String?;
    try {
      status = json['status'] as String;
    } catch (e) {
      print('Service.fromMap Error: Failed to parse status. Raw: ${json['status']}. Error: $e');
      rethrow;
    }
    try {
      createdAt = json['created_at'] as String;
    } catch (e) {
      print('Service.fromMap Error: Failed to parse created_at. Raw: ${json['created_at']}. Error: $e');
      rethrow;
    }
    try {
      updatedAt = json['updated_at'] as String;
    } catch (e) {
      print('Service.fromMap Error: Failed to parse updated_at. Raw: ${json['updated_at']}. Error: $e');
      rethrow;
    }

    return Service(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
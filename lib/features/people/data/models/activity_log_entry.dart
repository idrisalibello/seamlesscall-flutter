// lib/features/people/data/models/activity_log_entry.dart
class ActivityLogEntry {
  final int id;
  final int userId;
  final String action;
  final String? description;
  final String? ipAddress;
  final String? userAgent;
  final String createdAt;

  ActivityLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    this.description,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory ActivityLogEntry.fromMap(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      action: json['action'] as String,
      description: json['description'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'description': description,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt,
    };
  }
}
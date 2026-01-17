// lib/features/people/data/models/provider_model.dart
class Provider {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? companyName;
  final String? services; // Specialty
  final String? location;
  final int? isCompany;
  final int? isProvider;
  final String? providerStatus; // e.g., pending, approved, rejected
  final String? providerAppliedAt;
  final String? approvedBy; // admin_id
  final String? approvedAt;
  final String createdAt;

  Provider({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.companyName,
    this.services,
    this.location,
    this.isCompany,
    this.isProvider,
    this.providerStatus,
    this.providerAppliedAt,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
  });

  factory Provider.fromMap(Map<String, dynamic> json) {
    return Provider(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      companyName: json['company_name'] as String?,
      services: json['services'] as String?,
      location: json['location'] as String?,
      isCompany: json['is_company'] != null ? int.parse(json['is_company'].toString()) : null,
      isProvider: json['is_provider'] != null ? int.parse(json['is_provider'].toString()) : null,
      providerStatus: json['provider_status'] as String?,
      providerAppliedAt: json['provider_applied_at'] as String?,
      approvedBy: json['approved_by'] as String?, // Assuming int stored as string in JSON
      approvedAt: json['approved_at'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'company_name': companyName,
      'services': services,
      'location': location,
      'is_company': isCompany,
      'is_provider': isProvider,
      'provider_status': providerStatus,
      'provider_applied_at': providerAppliedAt,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
    };
  }
}
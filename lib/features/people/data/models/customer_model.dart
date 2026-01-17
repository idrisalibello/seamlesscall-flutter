// lib/features/people/data/models/customer_model.dart
class Customer {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? location;
  final String createdAt;
  final String? companyName;
  final int? isCompany;
  final int? isProvider; // For showing status if they applied
  final String? providerStatus; // For showing status if they applied

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.location,
    required this.createdAt,
    this.companyName,
    this.isCompany,
    this.isProvider,
    this.providerStatus,
  });

  factory Customer.fromMap(Map<String, dynamic> json) {
    return Customer(
      id: int.parse(json['id'].toString()), // Ensure int
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      location: json['location'] as String?,
      createdAt: json['created_at'] as String,
      companyName: json['company_name'] as String?,
      isCompany: json['is_company'] != null ? int.parse(json['is_company'].toString()) : null,
      isProvider: json['is_provider'] != null ? int.parse(json['is_provider'].toString()) : null,
      providerStatus: json['provider_status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'location': location,
      'created_at': createdAt,
      'company_name': companyName,
      'is_company': isCompany,
      'is_provider': isProvider,
      'provider_status': providerStatus,
    };
  }
}
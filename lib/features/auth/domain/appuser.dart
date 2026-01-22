import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appuser.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? role;
  final String? status;
  final List<String> permissions;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    required this.status,
    this.permissions = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    List<String>? permissions,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    status,
    permissions,
  ];
}

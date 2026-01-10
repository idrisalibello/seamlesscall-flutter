import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appuser.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String phone; // added
  final String role; // added

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
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
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, role];
}

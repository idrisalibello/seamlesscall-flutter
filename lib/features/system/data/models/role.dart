import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable()
class Role extends Equatable {
  final int id;
  @JsonKey(name: 'role_name')
  final String roleName;
  final String? description;

  const Role({
    required this.id,
    required this.roleName,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  @override
  List<Object?> get props => [id, roleName, description];
}

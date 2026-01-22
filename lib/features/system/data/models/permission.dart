import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'permission.g.dart';

@JsonSerializable()
class Permission extends Equatable {
  final int id;
  @JsonKey(name: 'group_name')
  final String groupName;
  @JsonKey(name: 'permission_name')
  final String permissionName;
  final String? description;

  const Permission({
    required this.id,
    required this.groupName,
    required this.permissionName,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);

  @override
  List<Object?> get props => [id, groupName, permissionName, description];
}

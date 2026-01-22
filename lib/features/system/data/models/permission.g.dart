// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Permission _$PermissionFromJson(Map<String, dynamic> json) => Permission(
  id: (json['id'] as num).toInt(),
  groupName: json['group_name'] as String,
  permissionName: json['permission_name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$PermissionToJson(Permission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_name': instance.groupName,
      'permission_name': instance.permissionName,
      'description': instance.description,
    };

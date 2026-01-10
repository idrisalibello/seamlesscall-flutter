// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appuser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String, // added
  role: json['role'] as String, // added
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone, // added
  'role': instance.role, // added
};

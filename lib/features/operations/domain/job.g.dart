// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
  id: (json['id'] as num).toInt(),
  customerId: (json['customer_id'] as num).toInt(),
  customerName: json['customer_name'] as String,
  customerPhone: json['customer_phone'] as String?,
  providerId: (json['provider_id'] as num?)?.toInt(),
  providerName: json['provider_name'] as String?,
  providerPhone: json['provider_phone'] as String?,
  serviceId: (json['service_id'] as num).toInt(),
  serviceName: json['service_name'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: json['status'] as String,
  scheduledTime: DateTime.parse(json['scheduled_time'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  assignedAt: json['assigned_at'] == null
      ? null
      : DateTime.parse(json['assigned_at'] as String),
  escalationReason: json['escalation_reason'] as String?,
  escalatedAt: json['escalated_at'] == null
      ? null
      : DateTime.parse(json['escalated_at'] as String),
  escalatedBy: (json['escalated_by'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'customer_name': instance.customerName,
  'customer_phone': instance.customerPhone,
  'provider_id': instance.providerId,
  'provider_name': instance.providerName,
  'provider_phone': instance.providerPhone,
  'service_id': instance.serviceId,
  'service_name': instance.serviceName,
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'scheduled_time': instance.scheduledTime.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'assigned_at': instance.assignedAt?.toIso8601String(),
  'escalation_reason': instance.escalationReason,
  'escalated_at': instance.escalatedAt?.toIso8601String(),
  'escalated_by': instance.escalatedBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

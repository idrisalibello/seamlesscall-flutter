import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

@JsonSerializable()
class Job extends Equatable {
  final int id;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String? customerPhone; // Added for job details
  @JsonKey(name: 'provider_id')
  final int? providerId;
  @JsonKey(name: 'provider_name')
  final String? providerName; // Added for admin view
  @JsonKey(name: 'provider_phone')
  final String? providerPhone; // Added for admin view
  @JsonKey(name: 'service_id')
  final int serviceId;
  @JsonKey(name: 'service_name')
  final String serviceName; // Added for display
  final String title;
  final String? description;
  final String status;
  @JsonKey(name: 'scheduled_time')
  final DateTime scheduledTime;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'assigned_at')
  final DateTime? assignedAt;
  @JsonKey(name: 'escalation_reason')
  final String? escalationReason;
  @JsonKey(name: 'escalated_at')
  final DateTime? escalatedAt;
  @JsonKey(name: 'escalated_by')
  final int? escalatedBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Job({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.providerId,
    this.providerName,
    this.providerPhone,
    required this.serviceId,
    required this.serviceName,
    required this.title,
    this.description,
    required this.status,
    required this.scheduledTime,
    this.completedAt,
    this.cancelledAt,
    this.assignedAt,
    this.escalationReason,
    this.escalatedAt,
    this.escalatedBy,

    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
    customerPhone,
    providerId,
    providerName,
    providerPhone,
    serviceId,
    serviceName,
    title,
    description,
    status,
    scheduledTime,
    completedAt,
    cancelledAt,
    assignedAt,
    assignedAt,
    createdAt,
    updatedAt,
    createdAt,
    updatedAt,
  ];
}

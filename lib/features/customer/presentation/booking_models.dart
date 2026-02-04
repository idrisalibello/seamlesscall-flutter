import 'package:flutter/material.dart';

enum BookingType { asap, scheduled }

@immutable
class BookingDraft {
  /// Optional for now. We'll pass it when Service Details has real IDs wired.
  final int? serviceId;

  final String serviceName;
  final BookingType type;
  final DateTime? scheduledAt;
  final String address;
  final String note;

  const BookingDraft({
    this.serviceId, // ✅ not required
    required this.serviceName,
    required this.type,
    required this.scheduledAt,
    required this.address,
    required this.note,
  });

  BookingDraft copyWith({
    int? serviceId,
    String? serviceName,
    BookingType? type,
    DateTime? scheduledAt,
    String? address,
    String? note,
  }) {
    return BookingDraft(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      note: note ?? this.note,
    );
  }

  String get typeLabel => type == BookingType.asap ? "ASAP" : "Scheduled";

  String get scheduleLabel {
    if (type == BookingType.asap) return "Today";
    if (scheduledAt == null) return "Pick date & time";
    final d = scheduledAt!;
    final two = (int v) => v.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)} • ${two(d.hour)}:${two(d.minute)}";
  }
}

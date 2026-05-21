import 'package:flutter/material.dart';

enum BookingType { asap, scheduled }

@immutable
class BookingDraft {
  final int? serviceId;
  final String serviceName;
  final BookingType type;
  final DateTime? scheduledAt;
  final String address;
  final String note;

  /// Set when a promotion is validated in BookingSummaryScreen.
  /// Sent to the backend in initializeInspectionPayment.
  final int? promotionId;

  /// The raw discount amount in NGN (or applicable currency).
  /// Used purely for display on the summary screen.
  final double discountApplied;

  const BookingDraft({
    this.serviceId,
    required this.serviceName,
    required this.type,
    required this.scheduledAt,
    required this.address,
    required this.note,
    this.promotionId,
    this.discountApplied = 0.0,
  });

  bool get hasPromotion => promotionId != null && discountApplied > 0;

  BookingDraft copyWith({
    int? serviceId,
    String? serviceName,
    BookingType? type,
    DateTime? scheduledAt,
    String? address,
    String? note,
    int? promotionId,
    double? discountApplied,
    bool clearPromotion = false,
  }) {
    return BookingDraft(
      serviceId:       serviceId       ?? this.serviceId,
      serviceName:     serviceName     ?? this.serviceName,
      type:            type            ?? this.type,
      scheduledAt:     scheduledAt     ?? this.scheduledAt,
      address:         address         ?? this.address,
      note:            note            ?? this.note,
      promotionId:     clearPromotion ? null : (promotionId ?? this.promotionId),
      discountApplied: clearPromotion ? 0.0  : (discountApplied ?? this.discountApplied),
    );
  }

  String get typeLabel => type == BookingType.asap ? 'ASAP' : 'Scheduled';

  String get scheduleLabel {
    if (type == BookingType.asap) return 'Today';
    if (scheduledAt == null) return 'Pick date & time';
    final d   = scheduledAt!;
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} • ${two(d.hour)}:${two(d.minute)}';
  }
}
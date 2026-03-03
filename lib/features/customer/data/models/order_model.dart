import 'package:flutter/material.dart';

class CustomerOrder {
  final String orderId; // display id e.g. SC-1042
  final String jobId; // numeric id as string for now
  final String serviceName;
  final String subtitle; // location text or short label
  final OrderStage stage;
  final PaymentState payment;
  final String amountText;
  final String updatedAt;

  const CustomerOrder({
    required this.orderId,
    required this.jobId,
    required this.serviceName,
    required this.subtitle,
    required this.stage,
    required this.payment,
    required this.amountText,
    required this.updatedAt,
  });

  String get primaryActionText => switch (payment) {
    PaymentState.inspectionDue => "Pay inspection",
    PaymentState.executionPending => "Approve & Pay",
    PaymentState.failed => "Retry payment",
    PaymentState.paid => "View receipt",
    PaymentState.inspectionPaid =>
      stage == OrderStage.quoteReady ? "Approve & Pay" : "View details",
  };

  bool get primaryIsDanger => payment == PaymentState.failed;
}

enum PaymentState {
  inspectionDue,
  inspectionPaid,
  executionPending,
  paid,
  failed;

  String get pill => switch (this) {
    PaymentState.inspectionDue => "Inspection due",
    PaymentState.inspectionPaid => "Inspection paid",
    PaymentState.executionPending => "Payment pending",
    PaymentState.paid => "Paid",
    PaymentState.failed => "Failed",
  };

  Color color(ColorScheme cs) => switch (this) {
    PaymentState.inspectionDue => cs.tertiary,
    PaymentState.inspectionPaid => cs.primary,
    PaymentState.executionPending => cs.secondary,
    PaymentState.paid => cs.primary,
    PaymentState.failed => Colors.red,
  };
}

enum OrderStage {
  requested,
  inspectionDue,
  enRoute,
  quoteReady,
  inProgress,
  completed,
  cancelled;

  bool get isActive =>
      this != OrderStage.completed && this != OrderStage.cancelled;

  String get label => switch (this) {
    OrderStage.requested => "Requested",
    OrderStage.inspectionDue => "Inspection",
    OrderStage.enRoute => "En route",
    OrderStage.quoteReady => "Quote ready",
    OrderStage.inProgress => "In progress",
    OrderStage.completed => "Completed",
    OrderStage.cancelled => "Cancelled",
  };

  IconData get icon => switch (this) {
    OrderStage.requested => Icons.receipt_long_rounded,
    OrderStage.inspectionDue => Icons.payments_rounded,
    OrderStage.enRoute => Icons.directions_car_rounded,
    OrderStage.quoteReady => Icons.description_rounded,
    OrderStage.inProgress => Icons.construction_rounded,
    OrderStage.completed => Icons.verified_rounded,
    OrderStage.cancelled => Icons.cancel_rounded,
  };

  Color color(ColorScheme cs) => switch (this) {
    OrderStage.requested => cs.primary,
    OrderStage.inspectionDue => cs.tertiary,
    OrderStage.enRoute => cs.primary,
    OrderStage.quoteReady => cs.secondary,
    OrderStage.inProgress => cs.primary,
    OrderStage.completed => cs.primary,
    OrderStage.cancelled => Colors.red,
  };
}

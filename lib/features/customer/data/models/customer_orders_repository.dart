import 'order_model.dart';

class CustomerOrdersRepository {
  /// Phase 3: UI implementation only.
  /// Backend ZIP does not expose customer job endpoints yet.
  /// So we keep mock data here, and later replace with real API calls
  /// without touching UI screens.
  Future<List<CustomerOrder>> getOrders() async {
    // small delay to simulate network; keeps UI loading state real
    await Future.delayed(const Duration(milliseconds: 350));

    return const [
      CustomerOrder(
        orderId: "SC-1042",
        jobId: "1042",
        serviceName: "AC Repair",
        subtitle: "Ikeja, Lagos",
        stage: OrderStage.enRoute,
        payment: PaymentState.inspectionPaid,
        amountText: "₦2,000 paid • Quote pending",
        updatedAt: "Today • 09:20",
      ),
      CustomerOrder(
        orderId: "SC-1039",
        jobId: "1039",
        serviceName: "Plumbing",
        subtitle: "Surulere, Lagos",
        stage: OrderStage.quoteReady,
        payment: PaymentState.executionPending,
        amountText: "₦2,000 paid • ₦11,000 pending",
        updatedAt: "Today • 08:05",
      ),
      CustomerOrder(
        orderId: "SC-1031",
        jobId: "1031",
        serviceName: "House Cleaning",
        subtitle: "Wuse, Abuja",
        stage: OrderStage.completed,
        payment: PaymentState.paid,
        amountText: "₦9,500 paid",
        updatedAt: "Jan 28 • 16:12",
      ),
      CustomerOrder(
        orderId: "SC-1028",
        jobId: "1028",
        serviceName: "Electrical",
        subtitle: "Garki, Abuja",
        stage: OrderStage.cancelled,
        payment: PaymentState.failed,
        amountText: "Payment failed",
        updatedAt: "Jan 26 • 10:45",
      ),
    ];
  }
}

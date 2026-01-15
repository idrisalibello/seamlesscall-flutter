import 'dart:developer';
import 'package:seamlesscall/features/dashboard/data/dashboard_api.dart';

class DashboardRepository {
  final DashboardApi _api;

  DashboardRepository({DashboardApi? api}) : _api = api ?? DashboardApi();

  Future<int> getTotalCustomers() async {
    final stats = await _api.getStats();
    final customerCount = stats['total_customers'] as int;
    log('[DashboardRepository] Parsed total customers: $customerCount');
    return customerCount;
  }

  Future<int> getTotalProviders() async {
    final stats = await _api.getStats();
    final providerCount = stats['total_providers'] as int;
    log('[DashboardRepository] Parsed total providers: $providerCount');
    return providerCount;
  }
}

import 'package:dio/dio.dart';
import 'package:seamlesscall/core/network/dio_client.dart';

class ReportsRepository {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getSummary({
    required String fromDate,
    required String toDate,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/overview',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
      },
      fallbackMessage: 'Failed to load reports overview',
    );

    final summary = Map<String, dynamic>.from(
      (raw['summary'] as Map?) ?? const <String, dynamic>{},
    );

    final jobsTotal = _num(summary['jobs_total']);
    final jobsCompleted = _num(summary['jobs_completed']);
    final jobsCancelled = _num(summary['jobs_cancelled']);
    final jobsEscalated = _num(summary['jobs_escalated']);
    final customersTotal = _num(summary['customers_total']);
    final providersTotal = _num(summary['providers_total']);
    final earningsTotal = _num(summary['earnings_total']);
    final payoutsTotal = _num(summary['payouts_total']);
    final refundsTotal = _num(summary['refunds_total']);

    final completionRate = jobsTotal > 0 ? (jobsCompleted / jobsTotal) * 100 : 0;
    final cancellationRate = jobsTotal > 0 ? (jobsCancelled / jobsTotal) * 100 : 0;

    return {
      'cards': [
        {'label': 'Total Jobs', 'value': jobsTotal},
        {'label': 'Completed Jobs', 'value': jobsCompleted},
        {'label': 'Cancelled Jobs', 'value': jobsCancelled},
        {'label': 'Escalated Jobs', 'value': jobsEscalated},
        {'label': 'Customers', 'value': customersTotal},
        {'label': 'Providers', 'value': providersTotal},
        {'label': 'Earnings', 'value': earningsTotal},
        {'label': 'Payouts', 'value': payoutsTotal},
        {'label': 'Refunds', 'value': refundsTotal},
        {'label': 'Completion Rate %', 'value': completionRate},
        {'label': 'Cancellation Rate %', 'value': cancellationRate},
      ],
      'rows': <Map<String, dynamic>>[],
      'notes': [
        'Executive summary for the selected period.',
        if (cancellationRate > 20)
          'Cancellation rate is elevated and may require operational review.',
        if (jobsEscalated > 0)
          'Escalated jobs detected in the selected period.',
      ],
      'breakdowns': {
        'business_health': [
          {'metric': 'Completion Rate %', 'value': completionRate},
          {'metric': 'Cancellation Rate %', 'value': cancellationRate},
        ],
        'capacity': [
          {'metric': 'Customers', 'value': customersTotal},
          {'metric': 'Providers', 'value': providersTotal},
        ],
        'financial_position': [
          {'metric': 'Earnings', 'value': earningsTotal},
          {'metric': 'Payouts', 'value': payoutsTotal},
          {'metric': 'Refunds', 'value': refundsTotal},
        ],
      },
      'meta': <String, dynamic>{},
      'pagination': {'page': 1, 'total_pages': 1},
    };
  }

  Future<Map<String, dynamic>> getOperationsReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? status,
    int? categoryId,
    int? providerId,
    String? search,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/operations',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
        if (status != null && status.isNotEmpty && status != 'All') 'status': status,
      },
      fallbackMessage: 'Failed to load operations report',
    );

    final summary = Map<String, dynamic>.from(
      (raw['summary'] as Map?) ?? const <String, dynamic>{},
    );

    var rows = ((raw['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final searchText = (search ?? '').trim().toLowerCase();
    if (searchText.isNotEmpty) {
      rows = rows.where((row) {
        final haystack = [
          row['title'],
          row['status'],
          row['service_name'],
          row['customer_name'],
          row['provider_name'],
          row['created_at'],
        ].join(' ').toLowerCase();
        return haystack.contains(searchText);
      }).toList();
    }

    final paged = _paginate(rows, page: page, pageSize: pageSize);

    final pending = _num(summary['pending']);
    final active = _num(summary['active']);
    final scheduled = _num(summary['scheduled']);
    final completed = _num(summary['completed']);
    final cancelled = _num(summary['cancelled']);
    final escalated = _num(summary['escalated']);

    return {
      'cards': [
        {'label': 'Pending', 'value': pending},
        {'label': 'Active', 'value': active},
        {'label': 'Scheduled', 'value': scheduled},
        {'label': 'Completed', 'value': completed},
        {'label': 'Cancelled', 'value': cancelled},
        {'label': 'Escalated', 'value': escalated},
      ],
      'rows': paged['rows'],
      'notes': [
        'Operational exceptions should be reviewed daily.',
        if (pending > completed) 'Pending jobs exceed completed jobs in this period.',
        if (escalated > 0) 'Escalated jobs require management attention.',
      ],
      'breakdowns': {
        'status_distribution': [
          {'status': 'pending', 'count': pending},
          {'status': 'active', 'count': active},
          {'status': 'scheduled', 'count': scheduled},
          {'status': 'completed', 'count': completed},
          {'status': 'cancelled', 'count': cancelled},
          {'status': 'escalated', 'count': escalated},
        ],
      },
      'meta': {
        'available_statuses': const [
          'pending',
          'active',
          'scheduled',
          'completed',
          'cancelled',
          'escalated',
        ],
        'providers': const <Map<String, dynamic>>[],
        'categories': const <Map<String, dynamic>>[],
      },
      'pagination': paged['pagination'],
    };
  }

  Future<Map<String, dynamic>> getProvidersReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? providerStatus,
    String? search,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/providers',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
      },
      fallbackMessage: 'Failed to load provider report',
    );

    var rows = ((raw['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final searchText = (search ?? '').trim().toLowerCase();
    if (searchText.isNotEmpty) {
      rows = rows.where((row) {
        final haystack = [
          row['provider_name'],
          row['average_rating'],
          row['earnings_total'],
        ].join(' ').toLowerCase();
        return haystack.contains(searchText);
      }).toList();
    }

    final paged = _paginate(rows, page: page, pageSize: pageSize);

    final topJobs = rows.isEmpty
        ? 0
        : rows.map((e) => _num(e['jobs_completed'])).reduce((a, b) => a > b ? a : b);
    final topRating = rows.isEmpty
        ? 0
        : rows.map((e) => _num(e['average_rating'])).reduce((a, b) => a > b ? a : b);
    final totalEarnings = rows.fold<num>(0, (sum, row) => sum + _num(row['earnings_total']));
    final totalDisputes = rows.fold<num>(0, (sum, row) => sum + _num(row['disputes']));

    return {
      'cards': [
        {'label': 'Providers Listed', 'value': rows.length},
        {'label': 'Top Completed Jobs', 'value': topJobs},
        {'label': 'Top Average Rating', 'value': topRating},
        {'label': 'Total Earnings', 'value': totalEarnings},
        {'label': 'Total Disputes', 'value': totalDisputes},
      ],
      'rows': paged['rows'],
      'notes': [
        'Providers are ranked by completed jobs in the backend.',
        if (totalDisputes > 0)
          'Disputes are present and should be reviewed alongside ratings.',
      ],
      'breakdowns': {
        'provider_leaderboard': rows.take(10).map((row) {
          return {
            'provider_name': row['provider_name'],
            'jobs_completed': row['jobs_completed'],
            'average_rating': row['average_rating'],
          };
        }).toList(),
      },
      'meta': {
        'available_provider_statuses': const <String>[],
      },
      'pagination': paged['pagination'],
    };
  }

  Future<Map<String, dynamic>> getCustomersReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? search,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/customers',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
      },
      fallbackMessage: 'Failed to load customer report',
    );

    var rows = ((raw['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final searchText = (search ?? '').trim().toLowerCase();
    if (searchText.isNotEmpty) {
      rows = rows.where((row) {
        final haystack = [
          row['customer_name'],
          row['jobs_total'],
          row['jobs_completed'],
          row['jobs_cancelled'],
        ].join(' ').toLowerCase();
        return haystack.contains(searchText);
      }).toList();
    }

    final paged = _paginate(rows, page: page, pageSize: pageSize);

    final totalJobs = rows.fold<num>(0, (sum, row) => sum + _num(row['jobs_total']));
    final totalCompleted = rows.fold<num>(0, (sum, row) => sum + _num(row['jobs_completed']));
    final totalCancelled = rows.fold<num>(0, (sum, row) => sum + _num(row['jobs_cancelled']));

    return {
      'cards': [
        {'label': 'Customers Listed', 'value': rows.length},
        {'label': 'Total Jobs', 'value': totalJobs},
        {'label': 'Completed Jobs', 'value': totalCompleted},
        {'label': 'Cancelled Jobs', 'value': totalCancelled},
      ],
      'rows': paged['rows'],
      'notes': [
        'Customer activity is sorted by total jobs descending.',
      ],
      'breakdowns': {
        'top_customers': rows.take(10).map((row) {
          return {
            'customer_name': row['customer_name'],
            'jobs_total': row['jobs_total'],
            'jobs_completed': row['jobs_completed'],
          };
        }).toList(),
      },
      'meta': <String, dynamic>{},
      'pagination': paged['pagination'],
    };
  }

  Future<Map<String, dynamic>> getFinanceReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    int? providerId,
    String? commissionStatus,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/finance',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
      },
      fallbackMessage: 'Failed to load finance report',
    );

    final summary = Map<String, dynamic>.from(
      (raw['summary'] as Map?) ?? const <String, dynamic>{},
    );

    final rows = ((raw['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final paged = _paginate(rows, page: page, pageSize: pageSize);

    return {
      'cards': [
        {'label': 'Earnings', 'value': _num(summary['earnings_total'])},
        {'label': 'Commissions', 'value': _num(summary['commission_total'])},
        {'label': 'Provider Net', 'value': _num(summary['provider_net_total'])},
        {'label': 'Payouts', 'value': _num(summary['payouts_total'])},
        {'label': 'Refunds', 'value': _num(summary['refunds_total'])},
      ],
      'rows': paged['rows'],
      'notes': [
        'Finance detail rows currently use ledger transactions.',
      ],
      'breakdowns': {
        'finance_summary': [
          {'metric': 'Earnings', 'value': _num(summary['earnings_total'])},
          {'metric': 'Commissions', 'value': _num(summary['commission_total'])},
          {'metric': 'Provider Net', 'value': _num(summary['provider_net_total'])},
          {'metric': 'Payouts', 'value': _num(summary['payouts_total'])},
          {'metric': 'Refunds', 'value': _num(summary['refunds_total'])},
        ],
      },
      'meta': {
        'commission_statuses': const <String>[],
        'providers': const <Map<String, dynamic>>[],
      },
      'pagination': paged['pagination'],
    };
  }

  Future<Map<String, dynamic>> getPromotionsReport({
    required String fromDate,
    required String toDate,
    required int page,
    required int pageSize,
    String? status,
    String? promotionType,
  }) async {
    final raw = await _getRaw(
      '/api/v1/admin/reports/promotions',
      queryParameters: {
        'from': fromDate,
        'to': toDate,
      },
      fallbackMessage: 'Failed to load promotions report',
    );

    final summary = Map<String, dynamic>.from(
      (raw['summary'] as Map?) ?? const <String, dynamic>{},
    );

    var rows = ((raw['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    if (status != null && status.isNotEmpty && status != 'All') {
      rows = rows.where((row) => '${row['status']}' == status).toList();
    }

    final paged = _paginate(rows, page: page, pageSize: pageSize);

    return {
      'cards': [
        {'label': 'Total Promotions', 'value': _num(summary['total'])},
        {'label': 'Active', 'value': _num(summary['active'])},
        {'label': 'Inactive', 'value': _num(summary['inactive'])},
      ],
      'rows': paged['rows'],
      'notes': [
        'Promotion performance is limited to configured promotion records because redemption linkage is not present in the current schema.',
      ],
      'breakdowns': {
        'promotion_status': [
          {'status': 'active', 'count': _num(summary['active'])},
          {'status': 'inactive', 'count': _num(summary['inactive'])},
        ],
      },
      'meta': {
        'statuses': const ['active', 'inactive'],
      },
      'pagination': paged['pagination'],
    };
  }

  Future<Map<String, dynamic>> _getRaw(
    String path, {
    required Map<String, dynamic> queryParameters,
    required String fallbackMessage,
  }) async {
    try {
      final cleanParams = Map<String, dynamic>.from(queryParameters)
        ..removeWhere((key, value) => value == null || value == '');

      final response = await _dioClient.dio.get(
        path,
        queryParameters: cleanParams,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }

      throw Exception('$fallbackMessage. Status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        '$fallbackMessage: ${e.response?.data['messages'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Map<String, dynamic> _paginate(
    List<Map<String, dynamic>> rows, {
    required int page,
    required int pageSize,
  }) {
    final total = rows.length;
    final safePageSize = pageSize <= 0 ? 20 : pageSize;
    final totalPages = total == 0 ? 1 : ((total + safePageSize - 1) ~/ safePageSize);
    final safePage = page < 1 ? 1 : (page > totalPages ? totalPages : page);
    final start = (safePage - 1) * safePageSize;
    final end = (start + safePageSize) > total ? total : (start + safePageSize);

    final pagedRows = total == 0 ? <Map<String, dynamic>>[] : rows.sublist(start, end);

    return {
      'rows': pagedRows,
      'pagination': {
        'page': safePage,
        'page_size': safePageSize,
        'total': total,
        'total_pages': totalPages,
      },
    };
  }

  num _num(dynamic value) {
    if (value is num) return value;
    if (value == null) return 0;
    return num.tryParse(value.toString()) ?? 0;
  }
}
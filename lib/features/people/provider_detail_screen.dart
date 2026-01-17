import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seamlesscall/features/people/data/people_repository.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';
import 'package:seamlesscall/features/people/data/models/earnings_entry.dart';
import 'package:seamlesscall/features/people/data/models/payout_entry.dart';
import 'package:seamlesscall/features/people/data/models/ledger_entry.dart';
import 'package:seamlesscall/features/people/data/models/refund.dart';
import 'package:seamlesscall/features/people/data/models/activity_log_entry.dart';

class ProviderDetailScreen extends StatefulWidget {
  final int providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final PeopleRepository _peopleRepository = PeopleRepository();

  Provider? _provider;
  List<EarningsEntry> _earnings = [];
  List<PayoutEntry> _payouts = [];
  List<LedgerEntry> _ledgerEntries = [];
  List<Refund> _refunds = [];
  List<ActivityLogEntry> _activityLogs = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final providerDetails =
          await _peopleRepository.getProviderDetails(widget.providerId);
      final earnings =
          await _peopleRepository.getProviderEarnings(widget.providerId);
      final payouts =
          await _peopleRepository.getProviderPayouts(widget.providerId);
      final ledger =
          await _peopleRepository.getUserLedger(widget.providerId);
      final refunds =
          await _peopleRepository.getUserRefunds(widget.providerId);
      final activity =
          await _peopleRepository.getUserActivityLog(widget.providerId);

      if (mounted) {
        setState(() {
          _provider = providerDetails;
          _earnings = earnings;
          _payouts = payouts;
          _ledgerEntries = ledger;
          _refunds = refunds;
          _activityLogs = activity;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Helper for displaying snackbars
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showLedgerDetail(BuildContext context, LedgerEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Transaction #${entry.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(entry.createdAt),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${entry.amount.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Reference'),
              subtitle: Text(entry.reference ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: Text(entry.description ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Type'),
              subtitle: Text(entry.transactionType),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEarningsDetail(BuildContext context, EarningsEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Earnings #${entry.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(entry.createdAt),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${entry.amount.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: Text(entry.description ?? 'N/A'),
            ),
            if (entry.jobId != null)
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Job ID'),
                subtitle: Text(entry.jobId.toString()),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPayoutDetail(BuildContext context, PayoutEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payout #${entry.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Requested At'),
              subtitle: Text(entry.requestedAt),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${entry.amount.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: Text(entry.status),
            ),
            if (entry.paymentMethod != null)
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Method'),
                subtitle: Text(entry.paymentMethod!),
              ),
            if (entry.transactionId != null)
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Transaction ID'),
                subtitle: Text(entry.transactionId!),
              ),
            if (entry.processedAt != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Processed At'),
                subtitle: Text(entry.processedAt!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          // TODO: Add buttons for approving/rejecting payouts if such an API exists
        ],
      ),
    );
  }

  void _showRefundDetail(BuildContext context, Refund refund) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Refund #${refund.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Submitted'),
              subtitle: Text(refund.submittedAt),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: Text(refund.status),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${refund.amount.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Reason'),
              subtitle: Text(refund.reason),
            ),
            if (refund.processedBy != null)
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Processed By'),
                subtitle: Text(refund.processedBy.toString()),
              ),
            if (refund.processedAt != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Processed At'),
                subtitle: Text(refund.processedAt!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (refund.status == 'pending')
            TextButton(
              onPressed: () => _updateRefundStatus(refund.id, 'approved'),
              child: const Text('Approve'),
            ),
          if (refund.status == 'pending')
            TextButton(
              onPressed: () => _updateRefundStatus(refund.id, 'rejected'),
              child: const Text('Reject'),
            ),
        ],
      ),
    );
  }

  Future<void> _updateRefundStatus(int refundId, String status) async {
    Navigator.pop(context); // Close dialog first
    setState(() {
      _isLoading = true; // Indicate loading for the screen
    });
    try {
      await _peopleRepository.updateRefundStatus(refundId, status);
      _showSnackBar('Refund ${status} successfully!');
      await _loadAllData(); // Refresh all data
    } catch (e) {
      _showSnackBar('Failed to ${status} refund: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(title: const Text('Provider Details')),
          body: const Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Provider Details')),
          body: Center(child: Text('Error: $_error')));
    }

    if (_provider == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Provider Details')),
          body: const Center(child: Text('Provider data not found.')));
    }

    // Provider is not null beyond this point
    final provider = _provider!;

    return DefaultTabController(
      length: 7, // 7 tabs for provider
      child: Scaffold(
        appBar: AppBar(
          title: Text(provider.name),
          bottom: const TabBar(
            isScrollable: true, // Allow scrolling for many tabs
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Earnings'),
              Tab(text: 'Ledger'),
              Tab(text: 'Payouts'),
              Tab(text: 'Performance'), // Placeholder tab
              Tab(text: 'Refunds'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header / Identity
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                provider.role,
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (provider.providerStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (provider.providerStatus == 'approved'
                                          ? Colors.green[100]
                                          : (provider.providerStatus == 'pending'
                                              ? Colors.orange[100]
                                              : Colors.red[100])),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  provider.providerStatus!,
                                  style: TextStyle(
                                    color: (provider.providerStatus == 'approved'
                                            ? Colors.green
                                            : (provider.providerStatus == 'pending'
                                                ? Colors.orange
                                                : Colors.red)),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (provider.companyName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              provider.companyName!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await _peopleRepository.messageUser(
                                      provider.id, 'Hello Provider!');
                                  _showSnackBar(
                                      'Message sent to ${provider.name}');
                                } catch (e) {
                                  _showSnackBar('Failed to send message: $e',
                                      isError: true);
                                }
                              },
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await _peopleRepository.escalateUser(
                                      provider.id, 'Urgent Issue');
                                  _showSnackBar('Escalated ${provider.name}');
                                } catch (e) {
                                  _showSnackBar('Failed to escalate: $e',
                                      isError: true);
                                }
                              },
                              icon: const Icon(Icons.flag),
                              label: const Text('Escalate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs content
            Expanded(
              child: TabBarView(
                children: [
                  // Overview Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Phone'),
                            subtitle: Text(provider.phone ?? 'N/A'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Email'),
                            subtitle: Text(provider.email),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Services'),
                            subtitle: Text(provider.services ?? 'N/A'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Location'),
                            subtitle: Text(provider.location ?? 'N/A'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Joined Date'),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(provider.createdAt))),
                          ),
                        ),
                        if (provider.providerAppliedAt != null)
                          Card(
                            child: ListTile(
                              title: const Text('Applied Date'),
                              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(provider.providerAppliedAt!))),
                            ),
                          ),
                        if (provider.approvedBy != null)
                          Card(
                            child: ListTile(
                              title: const Text('Approved By'),
                              subtitle: Text(provider.approvedBy!),
                            ),
                          ),
                        if (provider.approvedAt != null)
                          Card(
                            child: ListTile(
                              title: const Text('Approved At'),
                              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(provider.approvedAt!))),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Earnings Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _earnings.isEmpty
                        ? const Center(child: Text('No earnings entries.'))
                        : ListView.separated(
                            itemCount: _earnings.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = _earnings[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.money),
                                  title: Text('Earnings #${entry.id}'),
                                  subtitle: Text(
                                      'Date: ${entry.createdAt}\nDescription: ${entry.description ?? 'N/A'}'),
                                  trailing: Text(
                                      '₦${entry.amount.toStringAsFixed(2)}'),
                                  onTap: () => _showEarningsDetail(context, entry),
                                ),
                              );
                            },
                          ),
                  ),

                  // Ledger Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ledgerEntries.isEmpty
                        ? const Center(child: Text('No ledger entries.'))
                        : ListView.separated(
                            itemCount: _ledgerEntries.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = _ledgerEntries[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.receipt),
                                  title: Text(
                                      '${entry.transactionType} #${entry.id}'),
                                  subtitle: Text(
                                      'Date: ${entry.createdAt}\nRef: ${entry.reference ?? 'N/A'}'),
                                  trailing: Text(
                                      '₦${entry.amount.toStringAsFixed(2)}'),
                                  onTap: () => _showLedgerDetail(context, entry),
                                ),
                              );
                            },
                          ),
                  ),

                  // Payouts Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _payouts.isEmpty
                        ? const Center(child: Text('No payout entries.'))
                        : ListView.separated(
                            itemCount: _payouts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = _payouts[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.payment),
                                  title: Text('Payout #${entry.id}'),
                                  subtitle: Text(
                                      'Requested: ${entry.requestedAt}\nStatus: ${entry.status}'),
                                  trailing: Text(
                                      '₦${entry.amount.toStringAsFixed(2)}'),
                                  onTap: () => _showPayoutDetail(context, entry),
                                ),
                              );
                            },
                          ),
                  ),

                  // Performance Tab (Placeholder)
                  const Center(child: Text('Performance data goes here.')),

                  // Refunds & Disputes Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _refunds.isEmpty
                        ? const Center(child: Text('No refund requests.'))
                        : ListView.separated(
                            itemCount: _refunds.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final refund = _refunds[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.report),
                                  title: Text('Refund #${refund.id}'),
                                  subtitle: Text(
                                      'Status: ${refund.status}\nAmount: ₦${refund.amount.toStringAsFixed(2)}'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () => _showRefundDetail(context, refund),
                                ),
                              );
                            },
                          ),
                  ),

                  // Activity Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _activityLogs.isEmpty
                        ? const Center(child: Text('No activity logs.'))
                        : ListView.separated(
                            itemCount: _activityLogs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final activity = _activityLogs[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.history),
                                  title: Text(activity.action),
                                  subtitle: Text(
                                      '${activity.createdAt}\n${activity.description ?? 'N/A'}'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

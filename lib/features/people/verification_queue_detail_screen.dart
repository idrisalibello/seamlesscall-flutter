import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/people/data/verification_repository.dart';
import 'package:seamlesscall/features/people/presentation/verification_providers.dart';

class VerificationQueueDetailScreen extends ConsumerWidget {
  final int caseId;
  const VerificationQueueDetailScreen({required this.caseId, super.key});

  void _showReasonDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    Function(String) onConfirm,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Reason cannot be empty'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final reason = reasonController.text.trim();

              // 1) close this dialog first
              Navigator.pop(context);

              // 2) then run next step after dialog closes
              Future.microtask(() => onConfirm(reason));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _performAction(
    BuildContext context,
    WidgetRef ref,
    String actionName,
    Future<void> Function() action,
  ) async {
    // Show a confirmation dialog first
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $actionName'),
          content: Text('Are you sure you want to $actionName this case?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(actionName),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await action();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Case $actionName successfully!')),
        );
        ref.invalidate(verificationQueueProvider);
        ref.invalidate(verificationCaseDetailProvider(caseId));
        Navigator.pop(context); // Go back to the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to $actionName case: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(verificationCaseDetailProvider(caseId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verification Detail'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Documents'),
              Tab(text: 'Profile Info'),
              Tab(text: 'History / Notes'),
            ],
          ),
        ),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (caseDetail) => Column(
            children: [
              _buildHeader(context, caseDetail),
              _buildTabBarView(caseDetail),
            ],
          ),
        ),
        floatingActionButton: detailAsync.when(
          data: (caseDetail) => _buildActionButtons(context, ref, caseDetail),
          loading: () => null,
          error: (e, s) => null,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VerificationCase caseDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseDetail.providerName ??
                      'Provider ID: ${caseDetail.providerId}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.blue.shade900,
                  ),
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
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Provider',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          caseDetail.status,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        caseDetail.status,
                        style: TextStyle(
                          color: _getStatusColor(caseDetail.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(VerificationCase caseDetail) {
    return Expanded(
      child: TabBarView(
        children: [
          // Documents Tab (mock for now)
          const Center(child: Text("Documents view not implemented")),

          // Profile Info Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Phone'),
                  subtitle: Text(caseDetail.providerPhone ?? 'N/A'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Email'),
                  subtitle: Text(caseDetail.providerEmail ?? 'N/A'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Joined Date'),
                  subtitle: Text(
                    caseDetail.createdAt.toIso8601String().split('T').first,
                  ),
                ),
              ),
            ],
          ),

          // History / Notes Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (caseDetail.decisionReason != null)
                Card(
                  child: ListTile(
                    title: const Text('Decision Reason'),
                    subtitle: Text(caseDetail.decisionReason!),
                  ),
                ),
              if (caseDetail.escalationReason != null)
                Card(
                  child: ListTile(
                    title: const Text('Escalation Reason'),
                    subtitle: Text(caseDetail.escalationReason!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    VerificationCase caseDetail,
  ) {
    final repo = ref.read(verificationRepositoryProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'approve',
          onPressed: () => _performAction(
            context,
            ref,
            "Approve",
            () => repo.approveVerification(caseId),
          ),
          tooltip: 'Approve',
          backgroundColor: Colors.green,
          child: const Icon(Icons.check),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'reject',
          onPressed: () =>
              _showReasonDialog(context, ref, 'Reject Case', (reason) {
                _performAction(
                  context,
                  ref,
                  "Reject",
                  () => repo.rejectVerification(caseId, reason),
                );
              }),
          tooltip: 'Reject',
          backgroundColor: Colors.red,
          child: const Icon(Icons.close),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'escalate',
          onPressed: () =>
              _showReasonDialog(context, ref, 'Escalate Case', (reason) {
                _performAction(
                  context,
                  ref,
                  "Escalate",
                  () => repo.escalateVerification(caseId, reason),
                );
              }),
          tooltip: 'Escalate',
          backgroundColor: Colors.orange,
          child: const Icon(Icons.flag),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'escalated':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

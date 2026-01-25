import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';

class CancelledJobDetailsScreen extends ConsumerWidget {
  final int jobId;
  const CancelledJobDetailsScreen({super.key, required this.jobId});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
  
  // Re-use assign job dialog logic
  Future<void> _showReassignJobDialog(BuildContext context, WidgetRef ref) async {
    // Loading wrapper
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final providers = await ref.read(availableProvidersProvider.future);
      
      if (!context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available providers found.')),
        );
        return;
      }

      int? selectedProviderId;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reassign Job to Provider'),
          content: StatefulBuilder(
            builder: (ctx, setState) => DropdownButtonFormField<int>(
              value: selectedProviderId,
              hint: const Text('Select Provider'),
              items: providers.map((p) {
                final rawId = p['id'];
                final int? normalizedId = rawId is int ? rawId : int.tryParse(rawId.toString());
                if (normalizedId == null) return null;
                return DropdownMenuItem<int>(
                  value: normalizedId,
                  child: Text(p['name'].toString()),
                );
              }).whereType<DropdownMenuItem<int>>().toList(),
              onChanged: (value) => setState(() => selectedProviderId = value),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Assign')),
          ],
        ),
      );

      if (confirmed != true || selectedProviderId == null) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(operationsRepositoryProvider).assignJob(jobId, selectedProviderId!);
      
      if(!context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      ref.invalidate(cancelledJobsProvider);
      ref.invalidate(jobDetailsProvider((role: 'Admin', jobId: jobId)));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job reassigned successfully! Status is now Active.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if(context.mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reassign job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final jobAsync = ref.watch(jobDetailsProvider((role: 'Admin', jobId: jobId)));

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: jobAsync.when(
          data: (job) => Text(job.title),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Error'),
        ),
      ),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (job) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Card(
                color: Colors.blueGrey.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancelled Job Info',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Title: ${job.title}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Customer: ${job.customerName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Cancelled At: ${_formatDate(job.cancelledAt)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blueGrey.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showReassignJobDialog(context, ref),
                        child: const Text('Reassign Job'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
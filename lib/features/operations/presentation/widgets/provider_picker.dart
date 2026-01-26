import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/application/dispatch_providers.dart'; // Import dispatch_providers for invalidation

class ProviderPicker extends ConsumerStatefulWidget {
  final int jobId;
  final Function() onAssigned; // Callback to refresh parent list

  const ProviderPicker({
    super.key,
    required this.jobId,
    required this.onAssigned,
  });

  @override
  ConsumerState<ProviderPicker> createState() => _ProviderPickerState();
}

class _ProviderPickerState extends ConsumerState<ProviderPicker> {
  int? _selectedProviderId;
  bool _isAssigning = false;

  Future<void> _assignJob() async {
    if (_selectedProviderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a provider.')),
      );
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      final success = await ref
          .read(operationsRepositoryProvider)
          .assignJob(widget.jobId, _selectedProviderId!);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job assigned successfully!')),
        );
        // Invalidate specific lists as well to ensure the job is removed from its previous list
        ref.invalidate(pendingJobsProvider);
        ref.invalidate(scheduledJobsProvider);
        ref.invalidate(escalatedJobsProvider);
        
        // This will trigger dispatchQueueProvider to recompute
        widget.onAssigned(); 
        
        Navigator.of(context).pop(); // Close dialog
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to assign job.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning job: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableProvidersAsync = ref.watch(availableProvidersProvider);

    return AlertDialog(
      title: const Text('Assign Job to Provider'),
      content: availableProvidersAsync.when(
        loading: () => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => SizedBox(
          height: 100,
          child: Center(child: Text('Error loading providers: $err')),
        ),
        data: (providers) {
          if (providers.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('No providers available.')),
            );
          }
          return DropdownButtonFormField<int>(
            value: _selectedProviderId,
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
            onChanged: _isAssigning
                ? null
                : (value) {
                    setState(() {
                      _selectedProviderId = value;
                    });
                  },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: _isAssigning ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isAssigning ? null : _assignJob,
          child: _isAssigning
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}

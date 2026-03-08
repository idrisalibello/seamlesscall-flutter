import 'package:flutter/material.dart';
import 'package:seamlesscall/common/widgets/main_layout.dart';
import 'package:seamlesscall/features/config/data/models/promotion_model.dart';
import 'package:seamlesscall/features/config/data/promotion_repository.dart';
import 'package:seamlesscall/features/config/promotions_edit_screen.dart';

class PromotionsDetailsScreen extends StatefulWidget {
  final int promotionId;

  const PromotionsDetailsScreen({super.key, required this.promotionId});

  @override
  State<PromotionsDetailsScreen> createState() => _PromotionsDetailsScreenState();
}

class _PromotionsDetailsScreenState extends State<PromotionsDetailsScreen> {
  final PromotionRepository _repo = PromotionRepository();

  bool _loading = true;
  String? _error;
  Promotion? _promotion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final promotion = await _repo.getPromotion(widget.promotionId);
      setState(() => _promotion = promotion);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (_promotion == null) return;

    final next = _promotion!.status == 'active' ? 'inactive' : 'active';

    try {
      final updated = await _repo.updatePromotionStatus(_promotion!.id!, next);
      setState(() => _promotion = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promotion ${next == 'active' ? 'activated' : 'deactivated'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    if (_promotion == null) return;

    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete promotion'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    try {
      await _repo.deletePromotion(_promotion!.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _promotion == null
                    ? const Center(child: Text('Promotion not found'))
                    : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final p = _promotion!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promotion Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(p.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text(p.promotionType)),
            Chip(label: Text(p.discountLabel)),
            Chip(label: Text(p.status)),
          ],
        ),

        const SizedBox(height: 18),

        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Description'),
            subtitle: Text((p.description ?? '').isEmpty ? 'No description' : p.description!),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Target'),
            subtitle: Text(p.targetLabel),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Validity'),
            subtitle: Text(p.validityLabel),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.confirmation_number_outlined),
            title: const Text('Coupon code'),
            subtitle: Text((p.code ?? '').isEmpty ? 'Not applicable' : p.code!),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.countertops),
            title: const Text('Usage limit'),
            subtitle: Text(p.usageLimit == null ? 'Unlimited / not set' : '${p.usageLimit}'),
          ),
        ),

        const SizedBox(height: 24),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PromotionsEditScreen(existing: p),
                  ),
                );
                if (changed == true) {
                  await _load();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Promotion'),
            ),
            OutlinedButton.icon(
              onPressed: _toggleStatus,
              icon: const Icon(Icons.toggle_on),
              label: Text(p.status == 'active' ? 'Deactivate' : 'Activate'),
            ),
            OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
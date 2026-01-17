import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/data/models/service_model.dart';
import '../../common/widgets/main_layout.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;

  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final AdminRepository _adminRepository = AdminRepository();

  Category? _category;
  List<Service> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategoryAndServices();
  }

  Future<void> _loadCategoryAndServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final category = await _adminRepository.getCategoryDetails(
        widget.categoryId,
      );
      final services = await _adminRepository.getServicesByCategory(
        widget.categoryId,
      );

      if (mounted) {
        setState(() {
          _category = category;
          _services = services;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category Details')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category Details')),
        body: const Center(child: Text('Category not found.')),
      );
    }

    final category = _category!;

    return MainLayout(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Add Service'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => AddServiceModal(
                categoryId: category.id,
                onServiceAdded: _loadCategoryAndServices,
              ),
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _CategorySummaryCard(
                category: category,
                onCategoryUpdated: _loadCategoryAndServices,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Manage services under this category',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _services.isEmpty
                    ? const Center(
                        child: Text('No services found for this category.'),
                      )
                    : ListView.separated(
                        itemCount: _services.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          final isActive = service.status == 'active';

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => EditServiceModal(
                                  service: service,
                                  onServiceUpdated: _loadCategoryAndServices,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isActive
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.15),
                                    child: Icon(
                                      Icons.miscellaneous_services,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.description ??
                                              'No description provided.',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusPill(isActive: isActive),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- Category Summary ---------------- */

class _CategorySummaryCard extends StatefulWidget {
  final Category category;
  final VoidCallback onCategoryUpdated;

  const _CategorySummaryCard({
    required this.category,
    required this.onCategoryUpdated,
  });

  @override
  State<_CategorySummaryCard> createState() => _CategorySummaryCardState();
}

class _CategorySummaryCardState extends State<_CategorySummaryCard> {
  void _showEditCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditCategoryModal(
        category: widget.category,
        onCategoryUpdated: widget.onCategoryUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.category.status == 'active';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(widget.category.description ?? 'No description provided.'),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(isActive ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionChip(
                  icon: Icons.edit,
                  label: 'Edit Category',
                  onTap: _showEditCategoryModal,
                ),
                _ActionChip(
                  icon: Icons.toggle_on,
                  label: 'Deactivate',
                  onTap: () {},
                ),
                _ActionChip(
                  icon: Icons.attach_money,
                  label: 'Pricing',
                  onTap: () {},
                ),
                _ActionChip(
                  icon: Icons.public,
                  label: 'Coverage',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Reusable Widgets ---------------- */

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Edit Category Modal ---------------- */

class EditCategoryModal extends StatefulWidget {
  final Category category;
  final VoidCallback onCategoryUpdated;

  const EditCategoryModal({
    super.key,
    required this.category,
    required this.onCategoryUpdated,
  });

  @override
  State<EditCategoryModal> createState() => _EditCategoryModalState();
}

class _EditCategoryModalState extends State<EditCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepository();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
    _descriptionController.text = widget.category.description ?? '';
    _isActive = widget.category.status == 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _adminRepository.updateCategory(
          widget.category.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _isActive ? 'active' : 'inactive',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated successfully!')),
          );
          widget.onCategoryUpdated();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update category: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Edit Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _isActive,
              onChanged: (val) {
                setState(() => _isActive = val);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Add / Edit Service Modal ---------------- */

class AddServiceModal extends StatefulWidget {
  final int categoryId;
  final VoidCallback onServiceAdded;

  const AddServiceModal({
    super.key,
    required this.categoryId,
    required this.onServiceAdded,
  });

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepository();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _adminRepository.createService(
          widget.categoryId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _isActive ? 'active' : 'inactive',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service created successfully!')),
          );
          widget.onServiceAdded();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create service: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ServiceForm(
      title: 'Add Service',
      nameController: _nameController,
      descriptionController: _descriptionController,
      isActive: _isActive,
      onActiveChanged: (v) => setState(() => _isActive = v),
      onSubmit: _isLoading ? null : _submitForm,
      formKey: _formKey,
      isLoading: _isLoading,
    );
  }
}

class EditServiceModal extends StatefulWidget {
  final Service service;
  final VoidCallback onServiceUpdated;

  const EditServiceModal({
    super.key,
    required this.service,
    required this.onServiceUpdated,
  });

  @override
  State<EditServiceModal> createState() => _EditServiceModalState();
}

class _EditServiceModalState extends State<EditServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepository();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.service.name;
    _descriptionController.text = widget.service.description ?? '';
    _isActive = widget.service.status == 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _adminRepository.updateService(
          widget.service.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _isActive ? 'active' : 'inactive',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service updated successfully!')),
          );
          widget.onServiceUpdated();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update service: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ServiceForm(
      title: 'Edit Service',
      nameController: _nameController,
      descriptionController: _descriptionController,
      isActive: _isActive,
      onActiveChanged: (v) => setState(() => _isActive = v),
      onSubmit: _isLoading ? null : _submitForm,
      formKey: _formKey,
      isLoading: _isLoading,
    );
  }
}

/* ---------------- Shared Service Form ---------------- */

class _ServiceForm extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback? onSubmit;
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const _ServiceForm({
    required this.title,
    required this.nameController,
    required this.descriptionController,
    required this.isActive,
    required this.onActiveChanged,
    required this.onSubmit,
    required this.formKey,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: onActiveChanged,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

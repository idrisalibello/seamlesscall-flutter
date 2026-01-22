import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/system/application/roles_providers.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final int userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _statusValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    // Set initial values once the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(editUserNotifierProvider(widget.userId)).user;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        setState(() {
          _statusValue = user.status;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateFormFields(EditUserState state) {
    if (state.user != null) {
      _nameController.text = state.user!.name;
      _phoneController.text = state.user!.phone;
      if (_statusValue != state.user!.status) {
        // Post-frame callback to avoid calling setState during a build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _statusValue = state.user!.status;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editUserNotifierProvider(widget.userId));
    final notifier = ref.read(editUserNotifierProvider(widget.userId).notifier);
    final theme = Theme.of(context);

    // Update form fields when user data changes in the state
    ref.listen(editUserNotifierProvider(widget.userId), (_, next) {
      _updateFormFields(next);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isLoading
              ? 'Loading...'
              : 'Edit User: ${state.user?.name ?? ''}',
        ),
      ),
      body: state.isLoading && state.user == null
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text('Error: ${state.errorMessage}'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Details Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Details',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Name cannot be empty' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _statusValue,
                            decoration: const InputDecoration(
                              labelText: 'Account Status',
                            ),
                            items: ['active', 'pending', 'suspended'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value[0].toUpperCase() + value.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _statusValue = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await notifier
                                      .updateUserDetails({
                                        'name': _nameController.text,
                                        'phone': _phoneController.text,
                                        'status': _statusValue,
                                      });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'User details updated!'
                                              : 'Failed to update details.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('Save Details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Role Assignment Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assign Roles', style: theme.textTheme.titleLarge),
                        ...state.allRoles.map((role) {
                          return CheckboxListTile(
                            title: Text(role.roleName),
                            subtitle: Text(role.description ?? ''),
                            value: state.assignedRoleIds.contains(role.id),
                            onChanged: (bool? selected) {
                              if (selected != null) {
                                notifier.toggleRole(role.id);
                              }
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: () async {
                              final success = await notifier.saveUserRoles();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'User roles updated!'
                                          : 'Failed to update roles.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Save Roles'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

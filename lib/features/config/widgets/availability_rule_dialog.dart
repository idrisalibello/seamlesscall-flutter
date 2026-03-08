import 'package:flutter/material.dart';
import 'package:seamlesscall/features/config/data/availability_repository.dart';
import 'package:seamlesscall/features/config/data/models/availability_rule_model.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';

class AvailabilityRuleDialog extends StatefulWidget {
  final List<Category> categories;
  final AvailabilityRule? initialRule;

  const AvailabilityRuleDialog({
    super.key,
    required this.categories,
    this.initialRule,
  });

  @override
  State<AvailabilityRuleDialog> createState() => _AvailabilityRuleDialogState();
}

class _AvailabilityRuleDialogState extends State<AvailabilityRuleDialog> {
  final AvailabilityRepository _availabilityRepository =
      AvailabilityRepository();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _lgaCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  int? _categoryId;
  String _status = 'active';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _days = <String>{};
  bool _saving = false;

  static const List<Map<String, String>> _dayOptions = [
    {'value': 'mon', 'label': 'Mon'},
    {'value': 'tue', 'label': 'Tue'},
    {'value': 'wed', 'label': 'Wed'},
    {'value': 'thu', 'label': 'Thu'},
    {'value': 'fri', 'label': 'Fri'},
    {'value': 'sat', 'label': 'Sat'},
    {'value': 'sun', 'label': 'Sun'},
  ];

  @override
  void initState() {
    super.initState();
    final current = widget.initialRule;
    if (current != null) {
      _categoryId = current.categoryId;
      _stateCtrl.text = current.state;
      _lgaCtrl.text = current.lga;
      _cityCtrl.text = current.city;
      _status = current.status;
      _days.addAll(current.availabilityDays.map((e) => e.toLowerCase()));
      _startTime = _parseTime(current.availabilityTimeStart);
      _endTime = _parseTime(current.availabilityTimeEnd);
    }
  }

  @override
  void dispose() {
    _stateCtrl.dispose();
    _lgaCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _timeToApi(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _timeLabel(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_categoryId == null) {
      _showError('Category is required.');
      return;
    }

    if (_stateCtrl.text.trim().isEmpty) {
      _showError('State is required.');
      return;
    }

    if ((_startTime == null) != (_endTime == null)) {
      _showError('Start and end time must both be provided.');
      return;
    }

    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes <= startMinutes) {
        _showError('End time must be later than start time.');
        return;
      }
    }

    final payload = {
      'category_id': _categoryId,
      'state': _stateCtrl.text.trim(),
      'lga': _lgaCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'availability_days': _days.toList()..sort(),
      'availability_time_start': _timeToApi(_startTime),
      'availability_time_end': _timeToApi(_endTime),
      'status': _status,
    }..removeWhere((key, value) => value == null);

    setState(() => _saving = true);
    try {
      if (widget.initialRule == null) {
        await _availabilityRepository.createAvailabilityRule(payload);
      } else {
        await _availabilityRepository.updateAvailabilityRule(
          widget.initialRule!.id,
          payload,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialRule == null
            ? 'Add Availability Rule'
            : 'Edit Availability Rule',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stateCtrl,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lgaCtrl,
                decoration: const InputDecoration(
                  labelText: 'LGA',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Availability days',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dayOptions.map((day) {
                  final value = day['value']!;
                  final selected = _days.contains(value);
                  return FilterChip(
                    label: Text(day['label']!),
                    selected: selected,
                    onSelected: _saving
                        ? null
                        : (picked) {
                            setState(() {
                              if (picked) {
                                _days.add(value);
                              } else {
                                _days.remove(value);
                              }
                            });
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : () => _pickTime(true),
                      icon: const Icon(Icons.schedule),
                      label: Text('Start: ${_timeLabel(_startTime)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : () => _pickTime(false),
                      icon: const Icon(Icons.schedule_send),
                      label: Text('End: ${_timeLabel(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'inactive',
                    child: Text('Inactive'),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _status = value ?? 'active'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save),
          label: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/career_entry.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../../../../../core/themes/app_colors.dart';

class EditCareerScreen extends StatefulWidget {
  final PlayerProfileEntity profile;

  const EditCareerScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditCareerScreen> createState() => _EditCareerScreenState();
}

class _EditCareerScreenState extends State<EditCareerScreen> {
  late List<CareerEntry> _careerHistory;

  @override
  void initState() {
    super.initState();
    _careerHistory = List.from(widget.profile.careerHistory ?? []);
  }

  void _saveCareerHistory() {
    context.read<PlayerProfileBloc>().add(
          UpdatePlayerProfile(
            profileId: widget.profile.id ?? '',
            careerHistory: _careerHistory,
          ),
        );
  }

  void _addOrEditEntry({CareerEntry? entry, int? index}) {
    showDialog(
      context: context,
      builder: (context) => _CareerEntryDialog(
        entry: entry,
        onSave: (newEntry) {
          setState(() {
            if (index != null) {
              _careerHistory[index] = newEntry;
            } else {
              _careerHistory.add(newEntry);
            }
            // Sort by date descending
            _careerHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
          });
        },
      ),
    );
  }

  void _deleteEntry(int index) {
    setState(() {
      _careerHistory.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerProfileBloc, PlayerProfileState>(
      listener: (context, state) {
        if (state is PlayerProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('success.profile_updated'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is PlayerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Career History'),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            TextButton(
              onPressed: _saveCareerHistory,
              child: Text(
                'common.save'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: _careerHistory.isEmpty
            ? const Center(child: Text('No career history added yet.'))
            : ListView.builder(
                itemCount: _careerHistory.length,
                itemBuilder: (context, index) {
                  final entry = _careerHistory[index];
                  final dateFormat = DateFormat('MMM yyyy');
                  final dateRange =
                      '${dateFormat.format(entry.startDate)} - ${entry.isCurrent ? 'Present' : (entry.endDate != null ? dateFormat.format(entry.endDate!) : 'Unknown')}';

                  return ListTile(
                    title: Text(entry.clubName),
                    subtitle: Text(dateRange),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _addOrEditEntry(entry: entry, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditEntry(),
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _CareerEntryDialog extends StatefulWidget {
  final CareerEntry? entry;
  final Function(CareerEntry) onSave;

  const _CareerEntryDialog({
    Key? key,
    this.entry,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_CareerEntryDialog> createState() => _CareerEntryDialogState();
}

class _CareerEntryDialogState extends State<_CareerEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clubNameController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    _clubNameController = TextEditingController(text: widget.entry?.clubName ?? '');
    _startDate = widget.entry?.startDate;
    _endDate = widget.entry?.endDate;
    _isCurrent = widget.entry?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');

    return AlertDialog(
      title: Text(widget.entry == null ? 'Add Career Entry' : 'Edit Career Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _clubNameController,
                decoration: const InputDecoration(labelText: 'Club Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate != null
                    ? dateFormat.format(_startDate!)
                    : 'Select Date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              CheckboxListTile(
                title: const Text('Current Club'),
                value: _isCurrent,
                onChanged: (val) {
                  setState(() {
                    _isCurrent = val ?? false;
                    if (_isCurrent) _endDate = null;
                  });
                },
              ),
              if (!_isCurrent)
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(_endDate != null
                      ? dateFormat.format(_endDate!)
                      : 'Select Date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_startDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select start date')),
                );
                return;
              }
              if (!_isCurrent && _endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select end date')),
                );
                return;
              }

              widget.onSave(CareerEntry(
                clubName: _clubNameController.text,
                startDate: _startDate!,
                endDate: _endDate,
                isCurrent: _isCurrent,
              ));
              Navigator.of(context).pop();
            }
          },
          child: Text('common.save'.tr()),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../injection.dart';
import '../../../../../core/services/scout_service.dart';

class AddMatchReportScreen extends StatefulWidget {
  const AddMatchReportScreen({super.key});

  @override
  State<AddMatchReportScreen> createState() => _AddMatchReportScreenState();
}

class _AddMatchReportScreenState extends State<AddMatchReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentController = TextEditingController();
  final _locationController = TextEditingController();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _resultController = TextEditingController();
  final _mvpController = TextEditingController();
  DateTime? _matchDate;
  bool _isLoading = false;

  // Players to watch list
  final List<Map<String, TextEditingController>> _playersToWatch = [];

  @override
  void initState() {
    super.initState();
    _addPlayerField(); // Add one initial row
  }

  @override
  void dispose() {
    _tournamentController.dispose();
    _locationController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _resultController.dispose();
    _mvpController.dispose();
    for (var player in _playersToWatch) {
      player['name']?.dispose();
      player['jersey']?.dispose();
    }
    super.dispose();
  }

  void _addPlayerField() {
    setState(() {
      _playersToWatch.add({
        'name': TextEditingController(),
        'jersey': TextEditingController(),
      });
    });
  }

  void _removePlayerField(int index) {
    setState(() {
      final player = _playersToWatch[index];
      player['name']?.dispose();
      player['jersey']?.dispose();
      _playersToWatch.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _matchDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.scaffoldBackground,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _matchDate) {
      setState(() {
        _matchDate = picked;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_matchDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a match date')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final playersToWatch = _playersToWatch.map((p) => {
          'name': p['name']!.text,
          'jersey': p['jersey']!.text,
        }).toList();

        await getIt<ScoutService>().createMatchReport(
          tournamentName: _tournamentController.text,
          location: _locationController.text,
          matchDate: _matchDate!,
          teamA: _teamAController.text,
          teamB: _teamBController.text,
          result: _resultController.text,
          mvp: _mvpController.text.isNotEmpty ? _mvpController.text : null,
          playersToWatch: playersToWatch,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match Report Submitted Successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: const Text(
          'Add Match Report',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              : TextButton(
                  onPressed: _submitReport,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Match Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tournamentController,
                label: 'Tournament Name',
                icon: Icons.emoji_events_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Match Date',
                    prefixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                  ),
                  child: Text(
                    _matchDate == null
                        ? 'Select Date'
                        : DateFormat('MMM dd, yyyy').format(_matchDate!),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Teams & Result'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _teamAController,
                      label: 'Team A',
                      icon: Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _teamBController,
                      label: 'Team B',
                      icon: Icons.shield_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _resultController,
                label: 'Match Result (e.g. 2-1)',
                icon: Icons.scoreboard_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mvpController,
                label: 'MVP Player',
                icon: Icons.star_outline,
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Players to Watch'),
                  TextButton.icon(
                    onPressed: _addPlayerField,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Player'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._playersToWatch.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: player['name']!,
                          label: 'Player Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          controller: player['jersey']!,
                          label: 'Jersey #',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (_playersToWatch.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removePlayerField(index),
                        ),
                    ],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

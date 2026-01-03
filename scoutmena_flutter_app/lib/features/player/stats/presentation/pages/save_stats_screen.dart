import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/services/player_stats_service.dart';
import '../../../../../injection.dart';

class SaveStatsScreen extends StatefulWidget {
  final PlayerStatsResponse? stats;

  const SaveStatsScreen({Key? key, this.stats}) : super(key: key);

  @override
  State<SaveStatsScreen> createState() => _SaveStatsScreenState();
}

class _SaveStatsScreenState extends State<SaveStatsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seasonController = TextEditingController();
  String? _selectedLevel;
  final List<String> _levels = [
    'youth',
    'academy',
    'amateur',
    'semi_professional',
    'professional',
  ];
  final _goalsController = TextEditingController();
  final _assistsController = TextEditingController();
  final _appearancesController = TextEditingController();
  final _startsController = TextEditingController();
  final _yellowCardsController = TextEditingController();
  final _redCardsController = TextEditingController();
  final _minutesPlayedController = TextEditingController();
  final _playerStatsService = getIt<PlayerStatsService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.stats != null) {
      _seasonController.text = widget.stats!.season;
      _selectedLevel = widget.stats!.level;
      _goalsController.text = widget.stats!.goals.toString();
      _assistsController.text = widget.stats!.assists.toString();
      _appearancesController.text = widget.stats!.appearances.toString();
      _startsController.text = widget.stats!.starts.toString();
      _minutesPlayedController.text = widget.stats!.minutesPlayed.toString();
      if (widget.stats!.yellowCards != null) {
        _yellowCardsController.text = widget.stats!.yellowCards.toString();
      }
      if (widget.stats!.redCards != null) {
        _redCardsController.text = widget.stats!.redCards.toString();
      }
    }
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _goalsController.dispose();
    _assistsController.dispose();
    _appearancesController.dispose();
    _startsController.dispose();
    _yellowCardsController.dispose();
    _redCardsController.dispose();
    _minutesPlayedController.dispose();
    super.dispose();
  }

  Future<void> _saveStats() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (widget.stats == null) {
          // Create new stats
          await _playerStatsService.createStats(
            season: _seasonController.text,
            level: _selectedLevel!,
            goals: int.parse(_goalsController.text),
            assists: int.parse(_assistsController.text.isEmpty ? '0' : _assistsController.text),
            appearances: int.parse(_appearancesController.text.isEmpty ? '0' : _appearancesController.text),
            starts: int.parse(_startsController.text.isEmpty ? '0' : _startsController.text),
            minutesPlayed: int.parse(_minutesPlayedController.text.isEmpty ? '0' : _minutesPlayedController.text),
            yellowCards: _yellowCardsController.text.isEmpty ? null : int.parse(_yellowCardsController.text),
            redCards: _redCardsController.text.isEmpty ? null : int.parse(_redCardsController.text),
          );
        } else {
          // Update existing stats
          await _playerStatsService.updateStats(
            id: widget.stats!.id,
            season: _seasonController.text,
            level: _selectedLevel!,
            goals: int.parse(_goalsController.text),
            assists: int.parse(_assistsController.text.isEmpty ? '0' : _assistsController.text),
            appearances: int.parse(_appearancesController.text.isEmpty ? '0' : _appearancesController.text),
            starts: int.parse(_startsController.text.isEmpty ? '0' : _startsController.text),
            minutesPlayed: int.parse(_minutesPlayedController.text.isEmpty ? '0' : _minutesPlayedController.text),
            yellowCards: _yellowCardsController.text.isEmpty ? null : int.parse(_yellowCardsController.text),
            redCards: _redCardsController.text.isEmpty ? null : int.parse(_redCardsController.text),
          );
        }

        if (mounted) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('success.profile_updated'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save stats: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stats == null ? 'dashboard.update_stats'.tr() : 'Edit Stats'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'profile.career_stats'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seasonController,
              decoration: InputDecoration(
                labelText: 'profile.season'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              onChanged: (value) {
                if (value.length == 4 && RegExp(r'^\d{4}$').hasMatch(value)) {
                  _seasonController.text = '$value/';
                  _seasonController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _seasonController.text.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: InputDecoration(
                labelText: 'profile.competition_level'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.emoji_events),
              ),
              items: _levels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text('profile.levels.$level'.tr()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalsController,
              decoration: InputDecoration(
                labelText: 'profile.goals'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.sports_soccer),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assistsController,
              decoration: InputDecoration(
                labelText: 'profile.assists'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.verified),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appearancesController,
              decoration: InputDecoration(
                labelText: 'profile.appearances'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.event),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startsController,
              decoration: InputDecoration(
                labelText: 'profile.starts'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.play_circle_outline),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minutesPlayedController,
              decoration: InputDecoration(
                labelText: 'profile.minutes_played'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'errors.required_field'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yellowCardsController,
              decoration: InputDecoration(
                labelText: '${'profile.yellow_cards'.tr()} (${'common.optional'.tr()})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.warning_amber),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _redCardsController,
              decoration: InputDecoration(
                labelText: '${'profile.red_cards'.tr()} (${'common.optional'.tr()})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.warning),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('common.save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

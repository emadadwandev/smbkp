import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';

class EditAttributesScreen extends StatefulWidget {
  final PlayerProfileEntity profile;

  const EditAttributesScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditAttributesScreen> createState() => _EditAttributesScreenState();
}

class _EditAttributesScreenState extends State<EditAttributesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Technical Data Controllers
  final Map<String, double> _technicalData = {};
  
  // Tactical Data Controllers
  final Map<String, double> _tacticalData = {};
  
  // Physical Data Controllers
  final Map<String, double> _physicalData = {};
  
  // Training Data Controllers
  final TextEditingController _weeklyHoursController = TextEditingController();
  final TextEditingController _sessionsController = TextEditingController();
  final TextEditingController _focusAreaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    // Initialize Technical Data
    final tech = widget.profile.technicalData ?? {};
    _technicalData['ball_control'] = double.tryParse(tech['ball_control']?.toString() ?? '50') ?? 50;
    _technicalData['dribbling'] = double.tryParse(tech['dribbling']?.toString() ?? '50') ?? 50;
    _technicalData['passing'] = double.tryParse(tech['passing']?.toString() ?? '50') ?? 50;
    _technicalData['shooting'] = double.tryParse(tech['shooting']?.toString() ?? '50') ?? 50;
    _technicalData['defending'] = double.tryParse(tech['defending']?.toString() ?? '50') ?? 50;
    _technicalData['heading'] = double.tryParse(tech['heading']?.toString() ?? '50') ?? 50;

    // Initialize Tactical Data
    final tact = widget.profile.tacticalData ?? {};
    _tacticalData['positioning'] = double.tryParse(tact['positioning']?.toString() ?? '50') ?? 50;
    _tacticalData['vision'] = double.tryParse(tact['vision']?.toString() ?? '50') ?? 50;
    _tacticalData['decision_making'] = double.tryParse(tact['decision_making']?.toString() ?? '50') ?? 50;
    _tacticalData['work_rate'] = double.tryParse(tact['work_rate']?.toString() ?? '50') ?? 50;

    // Initialize Physical Data
    final phys = widget.profile.physicalData ?? {};
    _physicalData['speed'] = double.tryParse(phys['speed']?.toString() ?? '50') ?? 50;
    _physicalData['acceleration'] = double.tryParse(phys['acceleration']?.toString() ?? '50') ?? 50;
    _physicalData['strength'] = double.tryParse(phys['strength']?.toString() ?? '50') ?? 50;
    _physicalData['stamina'] = double.tryParse(phys['stamina']?.toString() ?? '50') ?? 50;
    _physicalData['agility'] = double.tryParse(phys['agility']?.toString() ?? '50') ?? 50;
    _physicalData['balance'] = double.tryParse(phys['balance']?.toString() ?? '50') ?? 50;

    // Initialize Training Data
    final train = widget.profile.trainingData ?? {};
    _weeklyHoursController.text = train['weekly_hours']?.toString() ?? '';
    _sessionsController.text = train['sessions_per_week']?.toString() ?? '';
    _focusAreaController.text = train['focus_area']?.toString() ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weeklyHoursController.dispose();
    _sessionsController.dispose();
    _focusAreaController.dispose();
    super.dispose();
  }

  void _saveAttributes() {
    final trainingData = {
      'weekly_hours': _weeklyHoursController.text,
      'sessions_per_week': _sessionsController.text,
      'focus_area': _focusAreaController.text,
    };

    // Convert doubles to ints for storage if needed, or keep as is
    final technicalData = _technicalData.map((key, value) => MapEntry(key, value.round()));
    final tacticalData = _tacticalData.map((key, value) => MapEntry(key, value.round()));
    final physicalData = _physicalData.map((key, value) => MapEntry(key, value.round()));

    context.read<PlayerProfileBloc>().add(
      UpdatePlayerProfile(
        profileId: widget.profile.id ?? '',
        technicalData: technicalData,
        tacticalData: tacticalData,
        physicalData: physicalData,
        trainingData: trainingData,
      ),
    );
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
          title: Text('profile.edit_attributes'.tr()),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            TextButton(
              onPressed: _saveAttributes,
              child: Text(
                'common.save'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(text: 'profile.technical'.tr()),
              Tab(text: 'profile.tactical'.tr()),
              Tab(text: 'profile.physical'.tr()),
              Tab(text: 'profile.training'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAttributeList(_technicalData),
            _buildAttributeList(_tacticalData),
            _buildAttributeList(_physicalData),
            _buildTrainingForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeList(Map<String, double> data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: data.keys.map((key) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'attributes.$key'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  data[key]!.round().toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ],
            ),
            Slider(
              value: data[key]!,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppColors.primaryBlue,
              label: data[key]!.round().toString(),
              onChanged: (value) {
                setState(() {
                  data[key] = value;
                });
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrainingForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _weeklyHoursController,
          decoration: InputDecoration(
            labelText: 'profile.weekly_hours'.tr(),
            border: const OutlineInputBorder(),
            suffixText: 'hours',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sessionsController,
          decoration: InputDecoration(
            labelText: 'profile.sessions_per_week'.tr(),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _focusAreaController,
          decoration: InputDecoration(
            labelText: 'profile.focus_area'.tr(),
            hintText: 'e.g., Stamina, Shooting accuracy',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}

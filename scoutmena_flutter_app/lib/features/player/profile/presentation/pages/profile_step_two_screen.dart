import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../domain/entities/academy_entity.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';

/// Step 2 of 4: Sport-Specific Data
/// Physical attributes, playing information, professional info
class ProfileStepTwoScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;

  const ProfileStepTwoScreen({
    super.key,
    required this.initialData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ProfileStepTwoScreen> createState() => _ProfileStepTwoScreenState();
}

class _ProfileStepTwoScreenState extends State<ProfileStepTwoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Physical attributes
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _preferredFoot;
  
  // Playing information
  String? _primaryPosition;
  List<String> _secondaryPositions = [];
  late TextEditingController _currentClubController;
  late TextEditingController _jerseyNumberController;
  DateTime? _careerStartDate;
  
  // Academy Info
  List<AcademyEntity> _academies = [];
  String? _selectedAcademyId;
  late TextEditingController _otherAcademyController;
  bool _isLoadingAcademies = false;
  
  // Professional info
  late TextEditingController _bioController;
  List<String> _achievements = [];
  late TextEditingController _agentNameController;
  late TextEditingController _agentEmailController;
  
  final List<String> _positions = [
    'goalkeeper',
    'center_back',
    'right_back',
    'left_back',
    'defensive_midfielder',
    'central_midfielder',
    'attacking_midfielder',
    'right_winger',
    'left_winger',
    'striker',
    'second_striker',
  ];
  
  final List<String> _footOptions = ['left', 'right', 'both'];

  @override
  void initState() {
    super.initState();
    
    _heightController = TextEditingController(
      text: widget.initialData['heightCm']?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.initialData['weightKg']?.toString() ?? '',
    );
    _preferredFoot = widget.initialData['preferredFoot'];
    
    _primaryPosition = widget.initialData['primaryPosition'];
    _secondaryPositions = List<String>.from(widget.initialData['secondaryPositions'] ?? []);
    _currentClubController = TextEditingController(
      text: widget.initialData['currentClub'] ?? '',
    );
    _jerseyNumberController = TextEditingController(
      text: widget.initialData['jerseyNumber']?.toString() ?? '',
    );
    _careerStartDate = widget.initialData['careerStartDate'];
    
    _selectedAcademyId = widget.initialData['academyId'];
    _otherAcademyController = TextEditingController(
      text: widget.initialData['academyName'] ?? '',
    );
    
    _bioController = TextEditingController(
      text: widget.initialData['bio'] ?? '',
    );
    _achievements = List<String>.from(widget.initialData['achievements'] ?? []);
    _agentNameController = TextEditingController(
      text: widget.initialData['agentName'] ?? '',
    );
    _agentEmailController = TextEditingController(
      text: widget.initialData['agentEmail'] ?? '',
    );

    // Load academies
    context.read<PlayerProfileBloc>().add(const LoadAcademies());
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _currentClubController.dispose();
    _jerseyNumberController.dispose();
    _otherAcademyController.dispose();
    _bioController.dispose();
    _agentNameController.dispose();
    _agentEmailController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_primaryPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.select_primary_position'.tr())),
        );
        return;
      }
      
      final data = {
        ...widget.initialData,
        'heightCm': _heightController.text.isNotEmpty 
            ? int.tryParse(_heightController.text) 
            : null,
        'weightKg': _weightController.text.isNotEmpty 
            ? int.tryParse(_weightController.text) 
            : null,
        'preferredFoot': _preferredFoot,
        'primaryPosition': _primaryPosition!,
        'secondaryPositions': _secondaryPositions,
        'currentClub': _currentClubController.text.trim(),
        'jerseyNumber': _jerseyNumberController.text.isNotEmpty 
            ? int.tryParse(_jerseyNumberController.text) 
            : null,
        'careerStartDate': _careerStartDate,
        'academyId': _selectedAcademyId == 'other' ? null : _selectedAcademyId,
        'academyName': _selectedAcademyId == 'other' ? _otherAcademyController.text.trim() : null,
        'bio': _bioController.text.trim(),
        'achievements': _achievements,
        'agentName': _agentNameController.text.trim(),
        'agentEmail': _agentEmailController.text.trim(),
      };
      
      widget.onNext(data);
    }
  }


  void _addAchievement(String achievement) {
    if (achievement.trim().isNotEmpty) {
      setState(() {
        _achievements.add(achievement.trim());
      });
    }
  }

  void _removeAchievement(int index) {
    setState(() {
      _achievements.removeAt(index);
    });
  }

  Future<void> _selectCareerStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _careerStartDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    if (picked != null) {
      setState(() {
        _careerStartDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerProfileBloc, PlayerProfileState>(
      listener: (context, state) {
        if (state is AcademiesLoaded) {
          setState(() {
            _academies = state.academies;
            _isLoadingAcademies = false;
          });
        } else if (state is PlayerProfileLoading) {
          // Optional: show loading indicator for academies
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('profile.create_profile'.tr()),
          backgroundColor: AppColors.primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(2),
                const SizedBox(height: 24),
                
                Text(
                  'profile.sport_data'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'profile.sport_data_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Physical Attributes
                _buildSectionTitle('profile.physical_attributes'.tr()),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        label: 'profile.height'.tr(),
                        controller: _heightController,
                        icon: Icons.height,
                        hint: 'cm',
                        required: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNumberField(
                        label: 'profile.weight'.tr(),
                        controller: _weightController,
                        icon: Icons.fitness_center,
                        hint: 'kg',
                        required: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildDropdown(
                  label: 'profile.preferred_foot'.tr(),
                  value: _preferredFoot,
                  items: _footOptions,
                  onChanged: (value) => setState(() => _preferredFoot = value),
                  itemBuilder: (foot) => 'profile.foot_$foot'.tr(),
                ),
                const SizedBox(height: 32),
                
                // Playing Information
                _buildSectionTitle('profile.playing_info'.tr()),
                const SizedBox(height: 16),
                
                _buildDropdown(
                  label: 'profile.primary_position'.tr(),
                  value: _primaryPosition,
                  items: _positions,
                  onChanged: (value) => setState(() => _primaryPosition = value),
                  itemBuilder: (pos) => 'positions.$pos'.tr(),
                  required: true,
                ),
                const SizedBox(height: 16),
                
                _buildMultiSelectChips(
                  label: 'profile.secondary_positions'.tr(),
                  selectedItems: _secondaryPositions,
                  allItems: _positions.where((p) => p != _primaryPosition).toList(),
                  onChanged: (selected) => setState(() => _secondaryPositions = selected),
                  itemBuilder: (pos) => 'positions.$pos'.tr(),
                  maxSelection: 3,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'profile.current_club'.tr(),
                  controller: _currentClubController,
                  icon: Icons.sports_soccer,
                  required: false,
                ),
                const SizedBox(height: 16),

                // Academy Selection
                _buildAcademyDropdown(),
                if (_selectedAcademyId == 'other') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'profile.academy_name'.tr(),
                    controller: _otherAcademyController,
                    icon: Icons.school,
                    required: true,
                    hint: 'profile.enter_academy_name'.tr(),
                  ),
                ],
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        label: 'profile.jersey_number'.tr(),
                        controller: _jerseyNumberController,
                        icon: Icons.numbers,
                        required: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'profile.career_start_date'.tr(),
                        date: _careerStartDate,
                        onTap: _selectCareerStartDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Professional Info
                _buildSectionTitle('profile.professional_info'.tr()),
                const SizedBox(height: 16),
                
                _buildTextArea(
                  label: 'profile.bio'.tr(),
                  controller: _bioController,
                  maxLength: 500,
                  hint: 'profile.bio_hint'.tr(),
                ),
                const SizedBox(height: 16),
                
                _buildAchievementsList(),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'profile.agent_name'.tr(),
                  controller: _agentNameController,
                  icon: Icons.person_outline,
                  required: false,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  label: 'profile.agent_email'.tr(),
                  controller: _agentEmailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  required: false,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'errors.invalid_email'.tr();
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onBack,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'common.previous'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'common.next'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAcademyId,
      decoration: InputDecoration(
        labelText: 'profile.academy'.tr() + ' (optional)'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        prefixIcon: Icon(Icons.school, color: AppColors.primaryBlue),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('common.none'.tr()),
        ),
        ..._academies.map((academy) {
          return DropdownMenuItem<String>(
            value: academy.id,
            child: Text(academy.name),
          );
        }).toList(),
        DropdownMenuItem<String>(
          value: 'other',
          child: Text('common.other'.tr()),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAcademyId = value;
        });
      },
    );
  }


  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primaryBlue
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    required int maxLength,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String Function(String) itemBuilder,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(itemBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? 'errors.field_required'.tr() : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd').format(date) : 'profile.select_date'.tr(),
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required String label,
    required List<String> selectedItems,
    required List<String> allItems,
    required Function(List<String>) onChanged,
    required String Function(String) itemBuilder,
    required int maxSelection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${'profile.max'.tr()} $maxSelection)',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allItems.map((item) {
            final isSelected = selectedItems.contains(item);
            final canSelect = selectedItems.length < maxSelection || isSelected;
            
            return FilterChip(
              label: Text(itemBuilder(item)),
              selected: isSelected,
              onSelected: canSelect
                  ? (selected) {
                      final newSelected = List<String>.from(selectedItems);
                      if (selected) {
                        newSelected.add(item);
                      } else {
                        newSelected.remove(item);
                      }
                      onChanged(newSelected);
                    }
                  : null,
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'profile.achievements'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            TextButton.icon(
              onPressed: _showAddAchievementDialog,
              icon: const Icon(Icons.add),
              label: Text('common.add'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_achievements.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'profile.no_achievements'.tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...List.generate(_achievements.length, (index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.emoji_events, color: AppColors.primaryBlue),
              title: Text(_achievements[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeAchievement(index),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _showAddAchievementDialog() async {
    final controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('profile.add_achievement'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'profile.achievement_hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              _addAchievement(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text('common.add'.tr()),
          ),
        ],
      ),
    );
  }
}

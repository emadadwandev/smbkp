import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../app/routes.dart';
import '../../../../../injection.dart';
import '../../../../authentication/domain/usecases/get_current_user_usecase.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import 'profile_step_one_screen.dart';
import 'profile_step_two_screen.dart';
import 'profile_step_three_screen.dart';
import 'profile_step_four_screen.dart';

/// Profile Creation Wrapper - Manages 4-step profile creation flow
class ProfileCreationScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const ProfileCreationScreen({
    super.key,
    required this.initialData,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  int _currentStep = 0;
  late Map<String, dynamic> _formData;
  bool _isLoadingUserData = false;
  bool _isMinor = false;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);
    
    // If initial data is empty, fetch current user data
    if (_formData.isEmpty) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase();
      
      result.fold(
        (failure) {
          print('Failed to fetch user data: ${failure.message}');
          // Continue with empty data or show error
        },
        (user) {
          // Split name into first and last name if possible
          String firstName = user.name;
          String lastName = '';
          
          if (user.name.contains(' ')) {
            final parts = user.name.split(' ');
            firstName = parts.first;
            lastName = parts.sublist(1).join(' ');
          }
          
          setState(() {
            _isMinor = user.isMinor;
            _formData = {
              'firstName': firstName,
              'lastName': lastName,
              'email': user.email,
              'phone': user.phone ?? '',
              'country': user.country ?? '',
              'dateOfBirth': user.dateOfBirth != null 
                  ? DateTime.tryParse(user.dateOfBirth!) 
                  : null,
              'accountType': user.accountType,
            };
          });
        },
      );
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  void _goToNextStep(Map<String, dynamic> data) {
    setState(() {
      _formData = {..._formData, ...data};
      if (_currentStep < 3) {
        _currentStep++;
      }
    });
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _completeProfile(Map<String, dynamic> data) {
    _formData = {..._formData, ...data};
    
    // Handle minor restrictions
    String privacyLevel = _formData['privacyLevel'] ?? 'scouts_only';
    String contactEmail = _formData['contactEmail'] ?? '';

    if (_isMinor) {
      // Force privacy level to scouts_only if public was selected
      if (privacyLevel == 'public') {
        privacyLevel = 'scouts_only';
      }
      // Allow contact email to be sent, backend will handle privacy
      // contactEmail = '';
    }

    // Dispatch create profile event to BLoC
    context.read<PlayerProfileBloc>().add(
      CreatePlayerProfile(
        firstName: _formData['firstName'] ?? '',
        lastName: _formData['lastName'] ?? '',
        nationality: _formData['nationality'] ?? '',
        city: _formData['city'] ?? '',
        country: _formData['country'] ?? '',
        heightCm: _formData['heightCm'],
        weightKg: _formData['weightKg'],
        preferredFoot: _formData['preferredFoot'],
        primaryPosition: _formData['primaryPosition'] ?? '',
        secondaryPositions: List<String>.from(_formData['secondaryPositions'] ?? []),
        currentClub: _formData['currentClub'],
        academyId: _formData['academyId'],
        academyName: _formData['academyName'],
        jerseyNumber: _formData['jerseyNumber'],
        careerStartDate: _formData['careerStartDate'],
        bio: _formData['bio'],
        achievements: List<String>.from(_formData['achievements'] ?? []),
        agentName: _formData['agentName'],
        agentEmail: _formData['agentEmail'],
        contactEmail: contactEmail,
        socialLinks: Map<String, String>.from(_formData['socialLinks'] ?? {}),
        privacyLevel: privacyLevel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerProfileBloc, PlayerProfileState>(
      listener: (context, state) {
        if (state is PlayerProfileCreated) {
          // Profile created successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('success.profile_created'.tr()),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          
          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed(AppRoutes.playerDashboard);
        } else if (state is PlayerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PlayerProfileLoading || _isLoadingUserData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  const SizedBox(height: 24),
                  Text(
                    _isLoadingUserData 
                        ? 'Loading user data...' 
                        : 'profile.creating_profile'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildStepScreen();
      },
    );
  }

  Widget _buildStepScreen() {
    switch (_currentStep) {
      case 0:
        return ProfileStepOneScreen(
          initialData: _formData,
          onNext: _goToNextStep,
        );
      case 1:
        return ProfileStepTwoScreen(
          initialData: _formData,
          onNext: _goToNextStep,
          onBack: _goToPreviousStep,
        );
      case 2:
        return ProfileStepThreeScreen(
          initialData: _formData,
          onNext: _goToNextStep,
          onBack: _goToPreviousStep,
        );
      case 3:
        return ProfileStepFourScreen(
          initialData: _formData,
          onComplete: _completeProfile,
          onBack: _goToPreviousStep,
        );
      default:
        return ProfileStepOneScreen(
          initialData: _formData,
          onNext: _goToNextStep,
        );
    }
  }
}

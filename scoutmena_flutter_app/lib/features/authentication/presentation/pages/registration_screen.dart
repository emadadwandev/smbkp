import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const RegistrationScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpService = getIt<OtpService>();
  final _secureStorage = getIt<FlutterSecureStorage>();

  String _selectedCountry = 'Jordan';
  String _selectedGender = 'male';
  DateTime? _selectedDateOfBirth;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Phone verification
  String? _verificationId;
  bool _isPhoneVerified = false;
  bool _isVerifyingPhone = false;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'JO'); // Default to Jordan

  // Parental consent fields (shown if age < 16)
  bool _requiresParentalConsent = false;
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String _parentRelationship = 'Mother';

  final List<String> _countries = [
    'Egypt',
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Qatar',
    'Bahrain',
    'Oman',
    'Jordan',
    'Lebanon',
    'Morocco',
    'Tunisia',
    'Algeria',
  ];

  final List<String> _relationships = [
    'Mother',
    'Father',
    'Legal Guardian',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber.isNotEmpty) {
      _phoneController.text = widget.phoneNumber;
      _isPhoneVerified = false;
      _parseInitialPhoneNumber(widget.phoneNumber);
    }
  }

  Future<void> _parseInitialPhoneNumber(String phoneNumber) async {
    try {
      PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
        phoneNumber,
      );
      if (mounted) {
        setState(() {
          _phoneNumber = number;
        });
      }
    } catch (e) {
      debugPrint('Error parsing phone number: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _checkAgeAndUpdateConsent() {
    if (_selectedDateOfBirth != null) {
      final age = _calculateAge(_selectedDateOfBirth!);
      setState(() {
        _requiresParentalConsent = age < 16;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
      _checkAgeAndUpdateConsent();
    }
  }

  Future<void> _verifyPhone() async {
    // Use the full phone number from the PhoneNumber object if available, otherwise controller text
    final phoneToVerify = _phoneNumber.phoneNumber ?? _phoneController.text;

    if (phoneToVerify.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('errors.required_field'.tr())));
      return;
    }

    setState(() => _isVerifyingPhone = true);

    try {
      final response = await _otpService.sendOtp(phoneNumber: phoneToVerify);

      if (mounted) {
        setState(() => _isVerifyingPhone = false);
        _showOtpDialog(response.verificationId, phoneToVerify);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifyingPhone = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
        );
      }
    }
  }

  void _showOtpDialog(String verificationId, String phoneNumber) {
    final otpController = TextEditingController();
    String currentVerificationId = verificationId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isResending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('auth.enter_otp'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('auth.otp_sent_to'.tr(args: [phoneNumber])),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'auth.otp_code'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isResending)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: () async {
                        setDialogState(() {
                          isResending = true;
                        });
                        try {
                          final response = await _otpService.sendOtp(
                            phoneNumber: phoneNumber,
                          );
                          currentVerificationId = response.verificationId;

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'auth.otp_sent'.tr() + ' $phoneNumber',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to resend OTP: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        } finally {
                          setDialogState(() {
                            isResending = false;
                          });
                        }
                      },
                      child: Text('auth.resend_otp'.tr()),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await _otpService.verifyOtp(
                        phoneNumber: phoneNumber,
                        otpCode: otpController.text,
                        verificationId: currentVerificationId,
                      );

                      if (response.verified) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          setState(() {
                            _isPhoneVerified = true;
                            _verificationId = currentVerificationId;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('auth.phone_verified'.tr()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Invalid OTP')));
                      }
                    }
                  },
                  child: Text('verify'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.must_agree_terms'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.select_date_of_birth'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isPhoneVerified || _verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.verify_phone_first'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_requiresParentalConsent) {
      if (_parentNameController.text.isEmpty ||
          _parentEmailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.parental_info_required'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the full phone number from the PhoneNumber object if available
      final phoneToRegister = _phoneNumber.phoneNumber ?? _phoneController.text;

      // Call registration API with OTP
      final response = await _otpService.registerWithOtp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: phoneToRegister,
        password: _passwordController.text,
        dateOfBirth: _selectedDateOfBirth!.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD format
        gender: _selectedGender,
        accountType: widget.role,
        country: _selectedCountry,
        verificationId: _verificationId!,
        parentName: _requiresParentalConsent
            ? _parentNameController.text
            : null,
        parentEmail: _requiresParentalConsent
            ? _parentEmailController.text
            : null,
        parentPhone:
            _requiresParentalConsent && _parentPhoneController.text.isNotEmpty
            ? _parentPhoneController.text
            : null,
        parentRelationship: _requiresParentalConsent
            ? _parentRelationship
            : null,
      );

      // Store auth data
      if (response.token != null && response.user != null) {
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: response.token!,
        );
        await _secureStorage.write(
          key: AppConstants.userIdKey,
          value: response.user!.id,
        );
        await _secureStorage.write(
          key: AppConstants.userRoleKey,
          value: response.user!.accountType,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.requiresParentalConsent) {
          // Navigate to awaiting consent screen
          Navigator.of(context).pushReplacementNamed(
            '/awaiting-consent',
            arguments: {
              'parentEmail':
                  response.parentalConsent?.parentEmail ??
                  _parentEmailController.text,
            },
          );
        } else {
          // Scout and Coach must upload verification documents first
          if (widget.role.toLowerCase() == 'scout' ||
              widget.role.toLowerCase() == 'coach') {
            Navigator.of(context).pushReplacementNamed(
              '/auth/verification-documents',
              arguments: {
                'userId': response.user!.id,
                'accountType': widget.role.toLowerCase(),
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'email': _emailController.text,
                'phone': phoneToRegister,
                'country': _selectedCountry,
              },
            );
          } else {
            // Player goes directly to profile setup
            Navigator.of(context).pushReplacementNamed(
              '/player/profile-setup',
              arguments: {
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'email': _emailController.text,
                'phone': phoneToRegister,
                'country': _selectedCountry,
                'dateOfBirth': _selectedDateOfBirth,
                'accountType': widget.role,
              },
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _openAcademyRegistration() async {
    final url = Uri.parse('https://scoutmena.com/register/academy');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.cannot_open_url'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.url_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Academy role requires web registration
    if (widget.role.toLowerCase() == 'academy') {
      return Scaffold(
        appBar: AppBar(
          title: Text('auth.academy_registration'.tr()),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Academy Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 80,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'auth.academy_registration_title'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'auth.academy_registration_description'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Open Registration Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _openAcademyRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: Text(
                        'auth.open_registration_form'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'back'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : AppColors.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'auth.academy_registration_note'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('auth.create_account'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(),
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'auth.role_${widget.role}'.tr(),
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'auth.first_name'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.required_field'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'auth.last_name'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.required_field'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'auth.email'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.required_field'.tr();
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'errors.invalid_email'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: true,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          initialValue: _phoneNumber,
                          textFieldController: _phoneController,
                          formatInput: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputBorder: InputBorder.none,
                          isEnabled: !_isPhoneVerified,
                          validator: _isPhoneVerified ? (val) => null : null,
                          inputDecoration: InputDecoration(
                            hintText: 'auth.phone_number'.tr(),
                            border: InputBorder.none,
                            suffixIcon: _isPhoneVerified
                                ? const Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    if (!_isPhoneVerified) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isVerifyingPhone ? null : _verifyPhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _isVerifyingPhone
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'verify'.tr(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'auth.date_of_birth'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _selectedDateOfBirth != null
                          ? DateFormat(
                              'yyyy-MM-dd',
                            ).format(_selectedDateOfBirth!)
                          : 'auth.select_date'.tr(),
                      style: TextStyle(
                        color: _selectedDateOfBirth != null
                            ? theme.textTheme.bodyMedium?.color
                            : theme.hintColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                Text(
                  'auth.gender'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('auth.male'.tr()),
                        value: 'male',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('auth.female'.tr()),
                        value: 'female',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Country
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'auth.country'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.public_outlined),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'auth.password'.tr(),
                    helperText: 'auth.password_instructions'.tr(),
                    helperMaxLines: 2,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.required_field'.tr();
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'auth.confirm_password'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'errors.required_field'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'errors.passwords_do_not_match'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Parental Consent Section (if age < 16)
                if (_requiresParentalConsent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.orange.withOpacity(0.2)
                          : AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.orange
                            : AppColors.orange.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.family_restroom,
                              color: isDark
                                  ? Colors.orange[300]
                                  : Colors.orange[900],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'auth.parental_consent_required'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.orange[300]
                                      : Colors.orange[900],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'auth.parental_consent_message'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Parent Name
                        TextFormField(
                          controller: _parentNameController,
                          decoration: InputDecoration(
                            labelText: 'auth.parent_name'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: isDark ? theme.cardColor : Colors.white,
                          ),
                          validator: _requiresParentalConsent
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'errors.required_field'.tr();
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Parent Relationship
                        DropdownButtonFormField<String>(
                          value: _parentRelationship,
                          decoration: InputDecoration(
                            labelText: 'auth.relationship'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: isDark ? theme.cardColor : Colors.white,
                          ),
                          items: _relationships.map((relationship) {
                            return DropdownMenuItem(
                              value: relationship,
                              child: Text(relationship),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _parentRelationship = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Parent Email
                        TextFormField(
                          controller: _parentEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'auth.parent_email'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: isDark ? theme.cardColor : Colors.white,
                          ),
                          validator: _requiresParentalConsent
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'errors.required_field'.tr();
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'errors.invalid_email'.tr();
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Parent Phone (optional)
                        TextFormField(
                          controller: _parentPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText:
                                'auth.parent_phone'.tr() + ' (optional)'.tr(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: isDark ? theme.cardColor : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Terms and Conditions
                CheckboxListTile(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            children: [
                              TextSpan(text: 'auth.i_agree_to'.tr() + ' '),
                              TextSpan(
                                text: 'auth.terms_and_conditions'.tr(),
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'auth.create_account'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        children: [
                          TextSpan(
                            text: 'auth.already_have_account'.tr() + ' ',
                          ),
                          TextSpan(
                            text: 'auth.login'.tr(),
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case 'player':
        return Icons.sports_soccer;
      case 'scout':
        return Icons.search;
      case 'coach':
        return Icons.sports;
      case 'academy':
        return Icons.school;
      default:
        return Icons.person;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../app/routes.dart';
//import '../../../../core/themes/app_colors.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../injection.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpService = getIt<OtpService>();
  PhoneNumber _initialNumber = PhoneNumber(isoCode: 'JO'); // Default Jordan
  String _fullPhoneNumber = '';
  String _selectedAccountType = 'player';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _accountTypes = ['player', 'scout', 'coach', 'academy'];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure we have a valid phone number
    if (_fullPhoneNumber.isEmpty) {
       setState(() {
        _errorMessage = 'errors.invalid_phone'.tr();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = _fullPhoneNumber;
      
      // Send OTP via Infobip backend
      final otpResponse = await _otpService.sendOtp(
        phoneNumber: phoneNumber,
        method: 'sms', // Can be 'sms' or 'whatsapp'
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Navigate to OTP verification screen
        Navigator.of(context).pushNamed(
          AppRoutes.otp,
          arguments: {
            'phone': phoneNumber,
            'verificationType': 'login',
            'verificationId': otpResponse.verificationId,
            'expiresAt': otpResponse.expiresAt.toIso8601String(),
            'accountType': _selectedAccountType,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _sendOTP,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Phone'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Verify Your Number',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send you a verification code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Account Type Selector
                Text(
                  'auth.account_type'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAccountType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _accountTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('auth.role_$type'.tr()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAccountType = value);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Phone Number Input
                Text(
                  'auth.phone_number'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _fullPhoneNumber = number.phoneNumber ?? '';
                  },
                  onInputValidated: (bool value) {
                    // Optional: handle validation state
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    useEmoji: true,
                    setSelectorButtonAsPrefixIcon: true,
                    leadingPadding: 12,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: Theme.of(context).textTheme.bodyMedium,
                  initialValue: _initialNumber,
                  textFieldController: _phoneController,
                  formatInput: false,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputDecoration: InputDecoration(
                    hintText: '1234567890',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSaved: (PhoneNumber number) {
                    _fullPhoneNumber = number.phoneNumber ?? '';
                  },
                ),
                const SizedBox(height: 8),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Send Verification Code',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back to Email Login
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text(
                      'Login with Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
}

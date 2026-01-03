import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../app/routes.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationType; // 'login' or 'register'
  final String? verificationId;
  final String? expiresAt;
  final String? accountType;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationType,
    this.verificationId,
    this.expiresAt,
    this.accountType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _otpService = getIt<OtpService>();
  final _secureStorage = getIt<FlutterSecureStorage>();

  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  String? _errorMessage;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    print('DEBUG: OTPVerificationScreen initialized with accountType: ${widget.accountType}'); // Debug print
    
    if (widget.verificationId != null) {
      _verificationId = widget.verificationId;
    }
    
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _resendTimer--;
        if (_resendTimer == 0) {
          _canResend = true;
        }
      });

      return _resendTimer > 0;
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Resend OTP via backend
      final otpResponse = await _otpService.sendOtp(
        phoneNumber: widget.phoneNumber,
        method: 'sms',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationId = otpResponse.verificationId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP resent to ${widget.phoneNumber}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to resend OTP'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification ID missing. Please request a new OTP.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, verify the OTP code
      await _otpService.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otpCode: otp,
        verificationId: _verificationId!,
      );

      if (widget.verificationType == 'login') {
        if (widget.accountType == null) {
          throw Exception('Account type is required for login');
        }

        // Login with OTP (using the now verified ID)
        final loginResponse = await _otpService.loginWithOtp(
          phone: widget.phoneNumber,
          verificationId: _verificationId!,
          accountType: widget.accountType!,
        );

        // Store authentication token
        print('DEBUG: Login successful. Token: ${loginResponse.token.substring(0, 10)}...');
        await _secureStorage.write(key: AppConstants.accessTokenKey, value: loginResponse.token);
        await _secureStorage.write(key: AppConstants.userIdKey, value: loginResponse.user.id);
        await _secureStorage.write(key: AppConstants.userRoleKey, value: loginResponse.user.accountType);

        // Register device for notifications
        try {
          final notificationService = getIt<NotificationService>();
          print('DEBUG: Calling registerDevice with token');
          await notificationService.registerDevice(authToken: loginResponse.token);
        } catch (e) {
          debugPrint('Failed to register device: $e');
        }

        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate to dashboard based on user role
          final route = _getDashboardRoute(loginResponse.user.accountType);
          Navigator.of(context).pushNamedAndRemoveUntil(
            route,
            (route) => false,
          );
        }
      } else {
        // Registration flow - OTP is already verified above
        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate to role selection for registration
          Navigator.of(context).pushNamed(
            AppRoutes.roleSelection,
            arguments: {'phone': widget.phoneNumber},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'OTP verification failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _verifyOTP,
            ),
          ),
        );
      }
    }
  }

  String _getDashboardRoute(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'player':
        return AppRoutes.playerDashboard;
      case 'scout':
        return AppRoutes.scoutDashboard;
      case 'coach':
        return AppRoutes.coachDashboard;
      default:
        return AppRoutes.playerDashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auth.enter_otp'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'auth.otp_sent'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }

                        // Auto-verify when all fields filled
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOTP();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

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

              // Verify Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
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
                          'auth.verify'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _canResend ? _resendOTP : null,
                    child: Text(
                      _canResend
                          ? 'auth.resend_otp'.tr()
                          : 'Resend in ${_resendTimer}s',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _canResend
                            ? AppColors.primaryBlue
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter the 6-digit code sent to your phone',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryBlue,
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
    );
  }
}

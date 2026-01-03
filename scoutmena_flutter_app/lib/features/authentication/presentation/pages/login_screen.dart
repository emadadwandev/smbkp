import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../app/routes.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late final OtpService _otpService;
  late final FlutterSecureStorage _secureStorage;

  @override
  void initState() {
    super.initState();
    _otpService = getIt<OtpService>();
    _secureStorage = getIt<FlutterSecureStorage>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() => _errorMessage = null);
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _otpService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Save authentication data
        await _secureStorage.write(key: AppConstants.accessTokenKey, value: response.token);
        await _secureStorage.write(key: AppConstants.userRoleKey, value: response.user.accountType);
        await _secureStorage.write(key: AppConstants.userIdKey, value: response.user.id);
        await _secureStorage.write(key: 'user_name', value: response.user.name);
        
        // Register device for notifications
        try {
          final notificationService = getIt<NotificationService>();
          await notificationService.registerDevice();
        } catch (e) {
          debugPrint('Failed to register device: $e');
        }

        // Navigate to appropriate dashboard based on account type
        String dashboardRoute;
        switch (response.user.accountType.toLowerCase()) {
          case 'player':
            dashboardRoute = AppRoutes.playerDashboard;
            break;
          case 'scout':
            dashboardRoute = AppRoutes.scoutDashboard;
            break;
          case 'coach':
            dashboardRoute = AppRoutes.coachDashboard;
            break;
          default:
            dashboardRoute = AppRoutes.main;
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.welcome_user'.tr(args: [response.user.name])),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          dashboardRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  void _navigateToPhoneLogin() {
    Navigator.of(context).pushNamed(AppRoutes.loginWithPhone);
  }

  Future<void> _signInWithGoogle() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('auth.google_sign_in_soon'.tr())),
    );
  }

  Future<void> _signInWithFacebook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('auth.facebook_sign_in_soon'.tr())),
    );
  }

  Future<void> _signInWithApple() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('auth.apple_sign_in_soon'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login'.tr()),
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
                  'auth.welcome_back'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'auth.sign_in_to_continue'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Email Field
                Text(
                  'auth.email'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    hintText: 'your.email@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.email_required'.tr();
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'auth.invalid_email'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password Field
                Text(
                  'auth.password'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'auth.enter_password'.tr(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.password_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'auth.password_min_length'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                    },
                    child: Text('auth.forgot_password'.tr()),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithEmail,
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
                            'auth.sign_in'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login with Phone Link
                Center(
                  child: TextButton.icon(
                    onPressed: _navigateToPhoneLogin,
                    icon: const Icon(Icons.phone_android),
                    label: Text(
                      'auth.login_with_mobile'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'auth.or_continue_with'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: _signInWithGoogle,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onTap: _signInWithFacebook,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: _signInWithApple,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.dont_have_account'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(AppRoutes.roleSelection);
                      },
                      child: Text(
                        'signup'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
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

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

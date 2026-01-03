import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/register_with_otp_usecase.dart';
import '../../domain/usecases/login_with_otp_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_firebase_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterWithOtpUseCase registerWithOtpUseCase;
  final LoginWithOtpUseCase loginWithOtpUseCase;
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final SignInWithFirebaseUseCase signInWithFirebaseUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerWithOtpUseCase,
    required this.loginWithOtpUseCase,
    required this.loginWithEmailUseCase,
    required this.signInWithFirebaseUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<RegisterWithOtpRequested>(_onRegisterWithOtpRequested);
    on<LoginWithOtpRequested>(_onLoginWithOtpRequested);
    on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<SignInWithFirebaseRequested>(_onSignInWithFirebaseRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isAuthenticated = await authRepository.isAuthenticated();

    if (isAuthenticated) {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => emit(const Unauthenticated()),
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendOtpUseCase(
      phoneNumber: event.phoneNumber,
      method: event.method,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (verificationId) => emit(OtpSent(
        verificationId: verificationId,
        phoneNumber: event.phoneNumber,
      )),
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await verifyOtpUseCase(
      phoneNumber: event.phoneNumber,
      otpCode: event.otpCode,
      verificationId: event.verificationId,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (verified) {
        if (verified) {
          emit(OtpVerified(phoneNumber: event.phoneNumber));
        } else {
          emit(const AuthError(message: 'Invalid OTP code'));
        }
      },
    );
  }

  Future<void> _onRegisterWithOtpRequested(
    RegisterWithOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerWithOtpUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      dateOfBirth: event.dateOfBirth,
      accountType: event.accountType,
      country: event.country,
      verificationId: event.verificationId,
      gender: event.gender,
      parentName: event.parentName,
      parentEmail: event.parentEmail,
      parentPhone: event.parentPhone,
      parentRelationship: event.parentRelationship,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResult) {
        if (authResult.requiresParentalConsent) {
          emit(RegistrationPendingParentalConsent(
            user: authResult.user,
            parentEmail: authResult.parentEmail ?? '',
            parentalConsentId: authResult.parentalConsentId ?? '',
          ));
        } else {
          // Save token if provided
          if (authResult.token != null) {
            authRepository.saveAuthToken(authResult.token!);
          }
          emit(RegistrationSuccess(authResult: authResult));
        }
      },
    );
  }

  Future<void> _onLoginWithOtpRequested(
    LoginWithOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginWithOtpUseCase(
      phoneNumber: event.phoneNumber,
      otpCode: event.otpCode,
      accountType: event.accountType,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResult) {
        // Save token
        if (authResult.token != null) {
          authRepository.saveAuthToken(authResult.token!);
        }
        emit(LoginSuccess(authResult: authResult));
      },
    );
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginWithEmailUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResult) {
        // Save token
        if (authResult.token != null) {
          authRepository.saveAuthToken(authResult.token!);
        }
        emit(LoginSuccess(authResult: authResult));
      },
    );
  }

  Future<void> _onSignInWithFirebaseRequested(
    SignInWithFirebaseRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithFirebaseUseCase(
      firebaseIdToken: event.firebaseIdToken,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResult) {
        // Save token
        if (authResult.token != null) {
          authRepository.saveAuthToken(authResult.token!);
        }
        emit(LoginSuccess(authResult: authResult));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {
        // Clear auth data
        authRepository.clearAuthData();
        emit(const LogoutSuccess());
      },
    );
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }
}

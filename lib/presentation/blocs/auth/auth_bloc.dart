import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(
          AuthState(
            status: repository.isAuthenticated
                ? AuthStatus.authenticated
                : AuthStatus.initial,
          ),
        ) {
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthResendRequested>(_onResendRequested);
    on<AuthBackToPhone>(_onBackToPhone);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onPhoneSubmitted(
    AuthPhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      phone: event.phoneNumber,
      clearVerificationId: true,
      clearError: true,
    ));
    try {
      final verificationId = await _repository.sendOtp(event.phoneNumber);
      if (verificationId == 'auto-verified') {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else {
        emit(state.copyWith(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.verificationId == null) return;
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _repository.verifyOtp(
        verificationId: state.verificationId!,
        otp: event.otp,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _onResendRequested(
    AuthResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.phone.isEmpty) return;
    add(AuthPhoneSubmitted(state.phone));
  }

  void _onBackToPhone(AuthBackToPhone event, Emitter<AuthState> emit) {
    emit(AuthState(phone: state.phone));
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.signOut();
    emit(const AuthState());
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح — تأكد من رمز الدولة';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً — يرجى المحاولة لاحقاً';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الرمز — أعد الإرسال';
      case 'quota-exceeded':
        return 'تجاوزت الحصة المسموحة — حاول لاحقاً';
      default:
        return e.message ?? 'حدث خطأ، يرجى المحاولة مرة أخرى';
    }
  }
}

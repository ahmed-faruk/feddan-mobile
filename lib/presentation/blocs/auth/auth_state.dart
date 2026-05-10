part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, otpSent, authenticated, failure }

final class AuthState extends Equatable {
  final AuthStatus status;
  final String phone;
  final String? verificationId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phone = '',
    this.verificationId,
    this.errorMessage,
  });

  /// True once the OTP has been sent and we're waiting for the user to enter it.
  bool get isOtpPhase => verificationId != null;

  bool get isSendingOtp =>
      status == AuthStatus.loading && verificationId == null;

  bool get isVerifyingOtp =>
      status == AuthStatus.loading && verificationId != null;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    String? verificationId,
    String? errorMessage,
    bool clearVerificationId = false,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        phone: phone ?? this.phone,
        verificationId:
            clearVerificationId ? null : (verificationId ?? this.verificationId),
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props =>
      [status, phone, verificationId, errorMessage];
}

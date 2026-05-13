part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthPhoneSubmitted extends AuthEvent {
  final String phoneNumber;
  const AuthPhoneSubmitted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthOtpSubmitted extends AuthEvent {
  final String otp;
  const AuthOtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

final class AuthResendRequested extends AuthEvent {
  const AuthResendRequested();
}

final class AuthBackToPhone extends AuthEvent {
  const AuthBackToPhone();
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

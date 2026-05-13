import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feddan/domain/repositories/auth_repository.dart';
import 'package:feddan/presentation/blocs/auth/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.isAuthenticated).thenReturn(false);
  });

  AuthBloc build() => AuthBloc(repository: repo);

  group('AuthBloc — initial state', () {
    test('is initial when not authenticated', () {
      expect(build().state.status, AuthStatus.initial);
    });

    test('is authenticated when repository reports authenticated', () {
      when(() => repo.isAuthenticated).thenReturn(true);
      expect(build().state.status, AuthStatus.authenticated);
    });
  });

  group('AuthPhoneSubmitted', () {
    const phone = '+201234567890';

    blocTest<AuthBloc, AuthState>(
      'emits loading then otpSent on success',
      build: () {
        when(() => repo.sendOtp(phone))
            .thenAnswer((_) async => 'verif-id-123');
        return build();
      },
      act: (b) => b.add(const AuthPhoneSubmitted(phone)),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.otpSent)
            .having((s) => s.verificationId, 'verificationId', 'verif-id-123')
            .having((s) => s.phone, 'phone', phone),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits loading then authenticated on Android auto-verify',
      build: () {
        when(() => repo.sendOtp(phone))
            .thenAnswer((_) async => 'auto-verified');
        return build();
      },
      act: (b) => b.add(const AuthPhoneSubmitted(phone)),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits loading then failure on FirebaseAuthException',
      build: () {
        when(() => repo.sendOtp(phone)).thenThrow(
          FirebaseAuthException(code: 'invalid-phone-number'),
        );
        return build();
      },
      act: (b) => b.add(const AuthPhoneSubmitted(phone)),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('AuthOtpSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated on valid OTP',
      build: () {
        when(() => repo.verifyOtp(
              verificationId: any(named: 'verificationId'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async {});
        return build();
      },
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        phone: '+201234567890',
        verificationId: 'verif-id-123',
      ),
      act: (b) => b.add(const AuthOtpSubmitted('123456')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure on wrong OTP',
      build: () {
        when(() => repo.verifyOtp(
              verificationId: any(named: 'verificationId'),
              otp: any(named: 'otp'),
            )).thenThrow(
          FirebaseAuthException(code: 'invalid-verification-code'),
        );
        return build();
      },
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        verificationId: 'verif-id-123',
      ),
      act: (b) => b.add(const AuthOtpSubmitted('000000')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.failure),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'does nothing when verificationId is null',
      build: () => build(),
      act: (b) => b.add(const AuthOtpSubmitted('123456')),
      expect: () => <AuthState>[],
    );
  });

  group('AuthGoogleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated on success',
      build: () {
        when(() => repo.signInWithGoogle()).thenAnswer((_) async {});
        return build();
      },
      act: (b) => b.add(const AuthGoogleSignInRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits initial when user cancels Google sheet',
      build: () {
        when(() => repo.signInWithGoogle()).thenThrow(
          FirebaseAuthException(code: 'sign-in-canceled'),
        );
        return build();
      },
      act: (b) => b.add(const AuthGoogleSignInRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.initial),
      ],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits initial state after sign-out',
      build: () {
        when(() => repo.signOut()).thenAnswer((_) async {});
        return build();
      },
      seed: () => const AuthState(status: AuthStatus.authenticated),
      act: (b) => b.add(const AuthSignOutRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.initial),
      ],
    );
  });

  group('AuthBackToPhone', () {
    blocTest<AuthBloc, AuthState>(
      'resets to initial and preserves phone number',
      build: () => build(),
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        phone: '+201234567890',
        verificationId: 'verif-id',
      ),
      act: (b) => b.add(const AuthBackToPhone()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.initial)
            .having((s) => s.verificationId, 'verificationId', isNull)
            .having((s) => s.phone, 'phone', '+201234567890'),
      ],
    );
  });
}

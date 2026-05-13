import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  bool get isAuthenticated => _remote.isAuthenticated;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Future<String> sendOtp(String phoneNumber) async {
    try {
      return await _remote.sendOtp(phoneNumber);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  @override
  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      await _remote.verifyOtp(verificationId: verificationId, otp: otp);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  @override
  Future<void> signOut() => _remote.signOut();
}

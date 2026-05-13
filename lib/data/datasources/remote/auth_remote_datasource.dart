import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  // H3: Single instance so signIn() and signOut() share the same internal
  // session state. Two separate GoogleSignIn() instances on iOS can hold
  // different cached accounts, making signOut() a no-op after a signIn().
  static final _googleSignIn = GoogleSignIn();

  const AuthRemoteDataSource(this._auth);

  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android-only: auto-verify without SMS code
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete('auto-verified');
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
        // When running against the local Auth Emulator, print the generated
        // OTP to the debug console so you don't need to look it up manually.
        const useEmulator = bool.fromEnvironment('USE_EMULATOR');
        if (useEmulator) _printEmulatorOtp();
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('⚠️ FirebaseAuthException code="${e.code}" message="${e.message}"');
      if (_auth.currentUser != null) return;
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Unknown auth error: ${e.runtimeType} — $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'sign-in-canceled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      if (_auth.currentUser != null) return;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Queries the local Firebase Auth Emulator and prints the generated OTP.
  // Only called when USE_EMULATOR=true — never included in release builds.
  static Future<void> _printEmulatorOtp() async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(
          'http://127.0.0.1:9099/emulator/v1/projects/feddan-mobile/verificationCodes'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final codes = (jsonDecode(body)['verificationCodes'] as List?) ?? [];
      if (codes.isNotEmpty) {
        final latest = codes.last as Map;
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📱 Emulator OTP → ${latest['code']}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
      client.close();
    } catch (_) {}
  }
}

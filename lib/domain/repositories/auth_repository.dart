abstract class AuthRepository {
  bool get isAuthenticated;
  String? get currentUserId;

  /// Sends OTP to [phoneNumber]. Returns verificationId, or 'auto-verified'
  /// on Android when Firebase auto-verifies without user input.
  Future<String> sendOtp(String phoneNumber);

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  });

  Future<void> signOut();
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/language/language_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isArabic =
            context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: state.isOtpPhase
                  ? _OtpSection(
                      key: const ValueKey('otp'),
                      state: state,
                      isArabic: isArabic,
                    )
                  : _PhoneSection(
                      key: const ValueKey('phone'),
                      state: state,
                      isArabic: isArabic,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Phone Section ────────────────────────────────────────────────────────────

class _PhoneSection extends StatefulWidget {
  final AuthState state;
  final bool isArabic;

  const _PhoneSection({
    super.key,
    required this.state,
    required this.isArabic,
  });

  @override
  State<_PhoneSection> createState() => _PhoneSectionState();
}

class _PhoneSectionState extends State<_PhoneSection> {
  final _countryCodeCtrl = TextEditingController(text: '+20');
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _countryCodeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _countryCodeCtrl.text.trim();
    final number = _phoneCtrl.text.trim();
    if (number.isEmpty) return;
    context.read<AuthBloc>().add(AuthPhoneSubmitted('$code$number'));
  }

  @override
  Widget build(BuildContext context) {
    final isSending = widget.state.isSendingOtp;
    final isArabic = widget.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          // Logo
          const Center(
            child: Text(
              'فدان',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isArabic
                  ? 'مساعدك الزراعي الذكي'
                  : 'Your Smart Farm Assistant',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 56),
          Text(
            isArabic ? 'سجل دخولك' : 'Sign In',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'أدخل رقم هاتفك لتلقي رمز التحقق'
                : 'Enter your phone number to receive a verification code',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          // Phone number input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code
              SizedBox(
                width: 72,
                child: TextFormField(
                  controller: _countryCodeCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'كود',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Phone number
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'رقم الهاتف' : 'Phone number',
                    hintText: isArabic ? '01X XXXX XXXX' : '01X XXXX XXXX',
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isSending ? null : _submit,
            child: isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isArabic ? 'إرسال رمز التحقق' : 'Send verification code',
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic
                ? 'سنرسل لك رمزاً مكوناً من 6 أرقام عبر رسالة نصية'
                : 'We\'ll send you a 6-digit code via SMS',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── OTP Section ──────────────────────────────────────────────────────────────

class _OtpSection extends StatefulWidget {
  final AuthState state;
  final bool isArabic;

  const _OtpSection({
    super.key,
    required this.state,
    required this.isArabic,
  });

  @override
  State<_OtpSection> createState() => _OtpSectionState();
}

class _OtpSectionState extends State<_OtpSection> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste of full OTP
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) _submit();
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otp.length == 6) _submit();
  }

  void _onKeyBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _submit() {
    if (_otp.length == 6) {
      context.read<AuthBloc>().add(AuthOtpSubmitted(_otp));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = widget.state.isVerifyingOtp;
    final isArabic = widget.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthBackToPhone()),
              icon: const Icon(Icons.arrow_back),
              label: Text(isArabic ? 'رجوع' : 'Back'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'أدخل رمز التحقق' : 'Enter verification code',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'أُرسل الرمز إلى ${widget.state.phone}'
                : 'Code sent to ${widget.state.phone}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          // 6-box OTP input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                width: 46,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event.logicalKey.keyLabel == 'Backspace') {
                      _onKeyBackspace(i);
                    }
                  },
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.textSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: (v) => _onDigitChanged(i, v),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isVerifying ? null : _submit,
            child: isVerifying
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(isArabic ? 'تحقق' : 'Verify'),
          ),
          const SizedBox(height: 24),
          Center(
            child: _ResendTimer(
              isArabic: isArabic,
              onResend: () =>
                  context.read<AuthBloc>().add(const AuthResendRequested()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Resend Timer ─────────────────────────────────────────────────────────────

class _ResendTimer extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onResend;

  const _ResendTimer({required this.isArabic, required this.onResend});

  @override
  State<_ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<_ResendTimer> {
  late Timer _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_seconds > 0) {
      return Text(
        widget.isArabic
            ? 'إعادة الإرسال خلال $_seconds ث'
            : 'Resend in ${_seconds}s',
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    return TextButton(
      onPressed: widget.onResend,
      child: Text(
        widget.isArabic ? 'إعادة إرسال الرمز' : 'Resend code',
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

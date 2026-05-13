import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
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
          NotificationService.requestPermission();
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
                  ? _OtpSection(key: const ValueKey('otp'), state: state)
                  : _PhoneSection(key: const ValueKey('phone'), state: state),
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
  const _PhoneSection({super.key, required this.state});

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
    final l10n = AppLocalizations.of(context)!;
    final isSending = widget.state.isSendingOtp;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.appName,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.tagline,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 56),
          Text(
            l10n.signIn,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.phoneSubtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: TextFormField(
                  controller: _countryCodeCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.countryCode,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: l10n.phoneLabel,
                    hintText: '01X XXXX XXXX',
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
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(l10n.sendCode),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.smsHint,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // ── OR divider ───────────────────────────────────────────────
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.orDivider,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isSending
                ? null
                : () => context
                    .read<AuthBloc>()
                    .add(const AuthGoogleSignInRequested()),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: Text(l10n.signInWithGoogle),
          ),
          const SizedBox(height: 16),
          // Language toggle
          Center(
            child: TextButton(
              onPressed: () => context.read<LanguageBloc>().add(
                    LanguageChanged(
                      isArabic ? const Locale('en') : const Locale('ar'),
                    ),
                  ),
              child: Text(
                isArabic ? 'English' : 'العربية',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OTP Section ──────────────────────────────────────────────────────────────

class _OtpSection extends StatefulWidget {
  final AuthState state;
  const _OtpSection({super.key, required this.state});

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
    if (_otp.length == 6 && !widget.state.isVerifyingOtp) {
      context.read<AuthBloc>().add(AuthOtpSubmitted(_otp));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isVerifying = widget.state.isVerifyingOtp;
    // LanguageBloc is watched so the widget rebuilds on locale change.
    context.watch<LanguageBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthBackToPhone()),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.back),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.enterCode,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.codeSentTo(widget.state.phone),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
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
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.textSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
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
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(l10n.verify),
          ),
          const SizedBox(height: 24),
          Center(
            child: _ResendTimer(
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
  final VoidCallback onResend;
  const _ResendTimer({required this.onResend});

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
      if (!mounted) {
        _timer.cancel();
        return;
      }
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
    final l10n = AppLocalizations.of(context)!;
    if (_seconds > 0) {
      return Text(
        l10n.resendIn(_seconds),
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    return TextButton(
      onPressed: widget.onResend,
      child: Text(
        l10n.resendCode,
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

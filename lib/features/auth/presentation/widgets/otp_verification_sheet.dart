import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../auth_providers.dart';

class OtpVerificationSheet extends ConsumerStatefulWidget {
  final String phone;
  final VoidCallback onSuccess;

  const OtpVerificationSheet({
    super.key,
    required this.phone,
    required this.onSuccess,
  });

  @override
  ConsumerState<OtpVerificationSheet> createState() =>
      _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends ConsumerState<OtpVerificationSheet> {
  final TextEditingController _otpController = TextEditingController();
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final token = _otpController.text.trim();
    if (token.length != 6) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyPhoneOtp(phone: widget.phone, token: token);

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onSuccess();
    }
  }

  void _resendOtp() async {
    if (_countdown > 0) return;
    await ref.read(authControllerProvider.notifier).sendPhoneOtp(widget.phone);
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title & Phone info
          Text(
            'Verify Mobile OTP',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit OTP code sent to\n${widget.phone}',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // OTP Input
          TextField(
            controller: _otpController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: const TextStyle(
                fontSize: 20,
                letterSpacing: 8,
                color: AppColors.textMuted,
              ),
              counterText: '',
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (val) {
              if (val.length == 6) {
                _verifyOtp();
              }
            },
          ),

          // Error Message
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lossBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lossBorder),
              ),
              child: Text(
                authState.errorMessage!,
                style: const TextStyle(color: AppColors.loss, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Verify Button
          ElevatedButton(
            onPressed: authState.isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Verify & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),

          const SizedBox(height: 16),

          // Resend Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _countdown > 0
                    ? 'Resend OTP in ${_countdown}s'
                    : "Didn't receive code?",
                style: AppTextStyles.bodySmall,
              ),
              if (_countdown == 0)
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text(
                    'Resend Now',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

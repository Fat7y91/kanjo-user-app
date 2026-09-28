import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_otp.dart';

final otpCodeProvider = StateProvider.autoDispose<String?>((ref) => null);

class OTPBottomSheet extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final bool isEmail;
  final bool isLoading;
  final Function(String otp) onVerify;
  final Function()? onResend;
  final int resendSeconds;

  const OTPBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.onVerify,
    this.onResend,
    this.isLoading = false,
    this.isEmail = false,
    this.resendSeconds = 30,
  });

  @override
  ConsumerState<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends ConsumerState<OTPBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  late int _currentTimerValue;
  bool _otpDisposed = false;

  @override
  void initState() {
    super.initState();
    _currentTimerValue = widget.resendSeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _currentTimerValue = widget.resendSeconds;
    setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _currentTimerValue--;
      if (_currentTimerValue >= 0) {
        Future.microtask(() {
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _maskLocalNumber(String phone) {
    final digits = localPhoneNumber(phone);
    if (digits.length <= 4) return digits;
    final startLen = digits.length > 8 ? 2 : 1;
    return '${digits.substring(0, startLen)}••••${digits.substring(digits.length - 4)}';
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    return '${email[0]}***${email.substring(at)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (!_otpDisposed) {
      _otpDisposed = true;
      _otpController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpCode = ref.watch(otpCodeProvider);
    final canResend = _currentTimerValue == 0;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "OTP".tr,
                        style: AppFont.font24w600Black.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    (widget.isEmail
                            ? "We've sent a 6-digit code to your email"
                            : "We've sent a 6-digit code to your phone number")
                        .tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Gap(8),
                  widget.isEmail
                      ? Text(
                          _maskEmail(widget.phoneNumber),
                          textDirection: TextDirection.ltr,
                          style: AppFont.font14W600Black.copyWith(
                            color: Colors.black87,
                          ),
                        )
                      : _PhoneDisplay(
                          countryCode: widget.countryCode,
                          phoneNumber: widget.phoneNumber,
                          maskLocal: _maskLocalNumber,
                        ),
                  const Gap(32),
                  CustomOTP(
                    controller: _otpController,
                    onChanged: (value) {
                      ref.read(otpCodeProvider.notifier).state = value;
                    },
                    onCompleted: (value) {
                      ref.read(otpCodeProvider.notifier).state = value;
                    },
                  ),
                  const Gap(24),
                  Center(
                    child: GestureDetector(
                      onTap: canResend
                          ? () {
                              if (widget.onResend != null) {
                                widget.onResend!();
                                _startTimer();
                              }
                            }
                          : null,
                      child: RichText(
                        text: TextSpan(
                          style: AppFont.font14W500Black.copyWith(
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(text: "Didn't receive the code? ".tr),
                            TextSpan(
                              text: canResend
                                  ? "Resend".tr
                                  : "Resend in %ss".trParams(
                                      {"s": _currentTimerValue.toString()}),
                              style: AppFont.font14W600Black.copyWith(
                                color: canResend
                                    ? AppColor.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(24),
                  // Verify button
                  CustomFilledButton(
                    text: "Verify".tr,
                    isValid: otpCode != null && otpCode.length == 6,
                    isLoading: widget.isLoading,
                    onPressed: () {
                      if (otpCode != null && otpCode.length == 6) {
                        widget.onVerify(otpCode);
                      }
                    },
                    textSize: 16,
                    color: AppColor.primary,
                    fontColor: Colors.white,
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneDisplay extends StatelessWidget {
  const _PhoneDisplay({
    required this.countryCode,
    required this.phoneNumber,
    required this.maskLocal,
  });

  final String countryCode;
  final String phoneNumber;
  final String Function(String phone) maskLocal;

  @override
  Widget build(BuildContext context) {
    final code = normalizeCountryCode(countryCode);
    final local = localPhoneNumber(phoneNumber, code);
    final masked = maskLocal(local);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          style: AppFont.font14W600Black.copyWith(color: Colors.black87),
          children: [
            if (code.isNotEmpty) ...[
              TextSpan(
                text: code,
                style: AppFont.font14W600Black.copyWith(
                  color: AppColor.primary,
                ),
              ),
              const TextSpan(text: '  '),
            ],
            TextSpan(text: masked),
          ],
        ),
      ),
    );
  }
}

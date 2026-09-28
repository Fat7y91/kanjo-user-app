import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/fcm_token_service.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/view/widgets/otp_bottom_sheet.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';

mixin RegisterActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, PhoneValidationMixin {
  FormGroup get formGroup;

  String get fullPhone {
    final countryCode = formGroup.control('country_code').value as String;
    final phone = formGroup.control('phone').value as String? ?? '';
    return buildE164Phone(countryCode, phone);
  }

  Future<void> onRegisterPressed() async {
    if (!formGroup.valid) {
      formGroup.markAllAsTouched();
      return;
    }

    try {
      final fcmToken =
          await getIt<FCMTokenService>().ensureFcmToken() ?? '';
      final registerResponse =
          await ref.read(authNotifierProvider.notifier).register({
        'name': formGroup.control('name').value,
        'email': formGroup.control('email').value,
        'phone': fullPhone,
        'password': formGroup.control('password').value,
        'password_confirmation':
            formGroup.control('password_confirmation').value,
        'gender': formGroup.control('gender').value,
        'profile_image': formGroup.control('profile_image').value as File?,
        'fcm_token': fcmToken,
      });

      if (registerResponse == null) return;

      final needsPhoneVerification =
          registerResponse.verificationRequired ||
              registerResponse.pendingVerification.contains('phone');

      if (needsPhoneVerification) {
        _showOtpSheet();
      } else if (registerResponse.token != null) {
        await ref.read(authNotifierProvider.notifier).handleUser(
              registerResponse,
              null,
              {'phone': fullPhone},
            );
      }
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }

  void _showOtpSheet() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final isLoading = sheetRef.watch(authNotifierProvider);
            return OTPBottomSheet(
              key: const ValueKey('otp-register'),
              phoneNumber: formGroup.control('phone').value as String? ?? '',
              countryCode:
                  formGroup.control('country_code').value as String? ?? '',
              isLoading: isLoading,
              resendSeconds: 60,
              onVerify: (otp) => _onVerifyOtp(sheetContext, otp),
              onResend: _onResendOtp,
            );
          },
        );
      },
    );
  }

  Future<void> _onResendOtp() async {
    try {
      await ref.read(authNotifierProvider.notifier).sendOtp({
        'phone': fullPhone,
        'purpose': 'verify_phone',
      });
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }

  Future<void> _onVerifyOtp(BuildContext sheetContext, String otp) async {
    try {
      Navigator.pop(sheetContext);
      await ref.read(authNotifierProvider.notifier).verifyOtp({
        'phone': fullPhone,
        'code': otp,
        'purpose': 'verify_phone',
      });
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }

  void goToLogin() {
    Get.back();
  }
}

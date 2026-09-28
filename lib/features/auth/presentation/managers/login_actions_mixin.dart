import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/fcm_token_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/view/forgot_password_page.dart';
import 'package:heraj/features/auth/presentation/view/register_page.dart';
import 'package:heraj/features/auth/presentation/view/widgets/otp_bottom_sheet.dart';
import 'package:heraj/features/root/view/root_view.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reactive_forms/reactive_forms.dart';

mixin LoginActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, PhoneValidationMixin {
  FormGroup get formGroup;

  String get fullPhone {
    final countryCode = formGroup.control('country_code').value as String;
    final phone = formGroup.control('phone').value as String? ?? '';
    return buildE164Phone(countryCode, phone);
  }

  Future<void> onLoginPressed() async {
    if (!formGroup.valid) {
      formGroup.markAllAsTouched();
      return;
    }

    try {
      final fcmToken =
          await getIt<FCMTokenService>().ensureFcmToken() ?? '';
      final loginResponse =
          await ref.read(authNotifierProvider.notifier).login({
        'phone': fullPhone,
        'password': formGroup.control('password').value,
        'fcm_token': fcmToken,
      });

      if (loginResponse == null) return;

      final needsPhoneVerification = loginResponse.verificationRequired ||
          loginResponse.pendingVerification.contains('phone');

      if (needsPhoneVerification) {
        _showOtpSheet();
      } else {
        await ref.read(authNotifierProvider.notifier).handleUser(
              loginResponse,
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
              key: const ValueKey('otp-login'),
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

  Future<void> authenticateWithFingerprint() async {
    final local = getIt<LocalAuthentication>();
    if (await local.authenticate(localizedReason: 'Authenticate To Login'.tr)) {
      Get.offAll(() => const RootView());
    }
  }

  void goToRegister() {
    Get.to(() => const RegisterPage());
  }

  void onForgotPasswordPressed() {
    Get.to(() => const ForgotPasswordPage());
  }

  Future<void> continueAsGuest() async {
    await dataManager.setGuest(true);
    Get.offAll(() => const RootView());
  }
}

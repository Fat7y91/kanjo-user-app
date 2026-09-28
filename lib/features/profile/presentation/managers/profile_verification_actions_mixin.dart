import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/auth/domain/use_cases/login_user_use_case.dart';
import 'package:heraj/features/auth/presentation/view/widgets/otp_bottom_sheet.dart';
import 'package:heraj/features/profile/presentation/manager/update_profile_provider.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:heraj/main.dart';
import 'package:heraj/models/user_model.dart';
import 'package:heraj/ui/ui.dart';

mixin ProfileVerificationActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _verificationInProgress = false;

  Future<void> startPendingVerification(
    PendingVerificationFailure failure,
  ) async {
    if (_verificationInProgress) return;
    _verificationInProgress = true;
    try {
      final user = ref.read(userProvider) ?? dataManager.getUser();
      final needsPhone = failure.needsPhone;
      final needsEmail = failure.needsEmail;
      if (!needsPhone && !needsEmail) return;

      if (needsEmail) {
        final verifiedEmail = await _verifyEmail(user);
        if (!verifiedEmail) return;
      }

      if (needsPhone) {
        final verifiedPhone = await _verifyPhone(user);
        if (!verifiedPhone) return;
      }

      if (!mounted) return;
      ref.invalidate(refreshProfileProvider);
    } finally {
      _verificationInProgress = false;
    }
  }

  Future<bool> _verifyPhone(UserModel? user) {
    return _verifyChannel(
      destination: localPhoneNumber(user?.phone ?? '', user?.countryCode),
      isEmail: false,
      countryCode: normalizeCountryCode(user?.countryCode),
    );
  }

  Future<bool> _verifyEmail(UserModel? user) {
    return _verifyChannel(
      destination: user?.email ?? '',
      isEmail: true,
      countryCode: '',
    );
  }

  Future<bool> _sendVerification({required bool isEmail}) async {
    final result = isEmail
        ? await getIt<SendEmailVerificationUseCase>().call()
        : await getIt<SendPhoneVerificationUseCase>().call();
    return result.fold((l) {
      UIHelper.showAlert(l.message, type: DialogType.error);
      return false;
    }, (r) {
      if (!r.success) {
        UIHelper.showAlert(
          r.message.isNotEmpty ? r.message : 'Failed to send OTP'.tr,
          type: DialogType.error,
        );
        return false;
      }
      return true;
    });
  }

  Future<bool> _verifyCode({
    required bool isEmail,
    required String code,
  }) async {
    final result = isEmail
        ? await getIt<VerifyEmailCodeUseCase>().call(code)
        : await getIt<VerifyPhoneCodeUseCase>().call(code);
    return result.fold((l) async {
      UIHelper.showAlert(l.message, type: DialogType.error);
      return false;
    }, (r) async {
      if (r.user != null) {
        ref.read(userProvider.notifier).state = r.user;
        await dataManager.setUser(r.user!);
      }
      return true;
    });
  }

  Future<bool> _verifyChannel({
    required String destination,
    required bool isEmail,
    required String countryCode,
  }) async {
    try {
      final sentOk = await _sendVerification(isEmail: isEmail);
      if (!sentOk) return false;
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
      return false;
    }

    if (!mounted) return false;

    final isLoading = ValueNotifier(false);
    try {
      final verified = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (_, loading, __) {
              return OTPBottomSheet(
                key: ValueKey(isEmail ? 'otp-email' : 'otp-phone'),
                phoneNumber: destination,
                countryCode: countryCode,
                isEmail: isEmail,
                isLoading: loading,
                onResend: () => _sendVerification(isEmail: isEmail),
                onVerify: (otp) async {
                  isLoading.value = true;
                  try {
                    final ok = await _verifyCode(isEmail: isEmail, code: otp);
                    if (ok && sheetContext.mounted) {
                      Navigator.pop(sheetContext, true);
                    }
                  } catch (e) {
                    UIHelper.showAlert(e.toString(), type: DialogType.error);
                  } finally {
                    isLoading.value = false;
                  }
                },
              );
            },
          );
        },
      );
      return verified == true;
    } finally {
      isLoading.dispose();
    }
  }
}

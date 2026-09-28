import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';

mixin ResetPasswordActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  FormGroup get formGroup;

  String get phone;

  Future<void> onResetPasswordPressed() async {
    if (!formGroup.valid) {
      formGroup.markAllAsTouched();
      return;
    }

    try {
      final response =
          await ref.read(authNotifierProvider.notifier).resetPassword({
        'phone': phone,
        'otp_code': formGroup.control('otp_code').value,
        'password': formGroup.control('password').value,
        'password_confirmation':
            formGroup.control('password_confirmation').value,
      });
      final message = response?.message ?? '';
      if (message.isNotEmpty) {
        await UIHelper.showAlert(message, type: DialogType.success);
      }
      if (!mounted) return;
      Get.offAll(() => const LoginPage());
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }

  Future<void> onResendResetCode() async {
    try {
      final response =
          await ref.read(authNotifierProvider.notifier).forgotPassword(phone);
      final message = response?.message ?? '';
      if (message.isNotEmpty) {
        UIHelper.showAlert(message, type: DialogType.success);
      }
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }
}

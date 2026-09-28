import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/auth/presentation/managers/auth_provuder.dart';
import 'package:heraj/features/auth/presentation/view/reset_password_page.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:heraj/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';

mixin ForgotPasswordActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, PhoneValidationMixin {
  FormGroup get formGroup;

  String get fullPhone {
    final countryCode = formGroup.control('country_code').value as String;
    final phone = formGroup.control('phone').value as String? ?? '';
    return buildE164Phone(countryCode, phone);
  }

  Future<void> onContinuePressed() async {
    if (!formGroup.valid) {
      formGroup.markAllAsTouched();
      return;
    }

    try {
      await ref.read(authNotifierProvider.notifier).forgotPassword(fullPhone);
      if (!mounted) return;
      Get.to(() => ResetPasswordPage(phone: fullPhone));
    } catch (e) {
      UIHelper.showAlert(e.toString(), type: DialogType.error);
    }
  }
}

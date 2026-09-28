import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../core/service/loading_provider.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/ui.dart';
import '../../../domain/use_cases/update_profile_use_case.dart';
import '../../manager/update_profile_provider.dart';
import '../../manager/upload_file_notifier.dart';

class EditProfileConfirmButton extends StatelessWidget with PhoneValidationMixin {
  const EditProfileConfirmButton({
    super.key,
    required this.formGroup,
  });

  final FormGroup formGroup;

  @override
  Widget build(BuildContext context) {
    return CustomReactiveFormValidationConsumer(
      formGroup: formGroup,
      builder: (BuildContext context, FormGroup form, Widget? child) {
        return Consumer(
          builder: (BuildContext context, ref, Widget? child) {
            final isLoading = ref.watch(isLoadingProvider('updateProfile'));
            return CustomFilledButton(
              isLoading: isLoading,
              isValid: form.valid,
              onPressed: () async => _confirmEditProfile(form, ref),
              text: 'Save'.tr,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmEditProfile(FormGroup form, WidgetRef ref) async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    try {
      ref.read(isLoadingProvider('updateProfile').notifier).state = true;

      final pickedFile = ref.read(profileImageFileProvider);
      final phone = buildE164Phone(
        form.control('countryCode').value?.toString() ?? '+20',
        form.control('phone').value?.toString() ?? '',
      );

      final requestBody = <String, dynamic>{
        'name': form.control('name').value,
        'email': form.control('email').value,
        'phone': phone,
        'birthdate': form.control('birthdate').value,
        'gender': form.control('gender').value,
        if (pickedFile != null) 'profile_image': pickedFile,
      };

      requestBody.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty),
      );

      final res = await getIt<UpdateProfileUseCase>().call(requestBody);
      res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
        },
        (r) {
          UIHelper.showAlert(r);
          ref.read(profileImageFileProvider.notifier).state = null;
          ref.invalidate(refreshProfileProvider);
        },
      );
    } finally {
      ref.read(isLoadingProvider('updateProfile').notifier).state = false;
    }
  }
}

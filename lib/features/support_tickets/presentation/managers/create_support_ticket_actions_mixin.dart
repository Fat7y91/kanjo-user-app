import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/support_tickets/domain/entities/create_support_ticket_params.dart';
import 'package:heraj/features/support_tickets/domain/use_case/support_tickets_use_cases.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'support_tickets_provider.dart';

mixin CreateSupportTicketActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  FormGroup get form;
  ValueNotifier<File?> get attachmentNotifier;

  Future<void> pickAttachment() async {
    final file = await getIt<ImagePickerService>().pickImage(crop: false);
    if (file == null) return;
    attachmentNotifier.value = file;
  }

  void removeAttachment() {
    attachmentNotifier.value = null;
  }

  Future<void> submitTicket() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    const loadingKey = 'createSupportTicket';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<CreateSupportTicketUseCase>().call(
        CreateSupportTicketParams(
          title: (form.control('title').value as String? ?? '').trim(),
          description:
              (form.control('description').value as String? ?? '').trim(),
          attachmentPath: attachmentNotifier.value?.path,
        ),
      );
      await result.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchSupportTicketsProvider);
          await UIHelper.showAlert(
            'Support ticket created successfully'.tr,
            type: DialogType.success,
          );
          if (!mounted) return;
          Get.back(result: true);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}

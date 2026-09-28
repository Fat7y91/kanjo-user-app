import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/support_tickets/presentation/managers/create_support_ticket_actions_mixin.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:reactive_forms/reactive_forms.dart';

Future<bool?> showCreateSupportTicketBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: const CreateSupportTicketBottomSheet(),
    ),
  );
}

class CreateSupportTicketBottomSheet extends ConsumerStatefulWidget {
  const CreateSupportTicketBottomSheet({super.key});

  @override
  ConsumerState<CreateSupportTicketBottomSheet> createState() =>
      _CreateSupportTicketBottomSheetState();
}

class _CreateSupportTicketBottomSheetState
    extends ConsumerState<CreateSupportTicketBottomSheet>
    with CreateSupportTicketActionsMixin {
  late final FormGroup formGroup;
  late final ValueNotifier<File?> _attachmentNotifier;

  @override
  FormGroup get form => formGroup;

  @override
  ValueNotifier<File?> get attachmentNotifier => _attachmentNotifier;

  @override
  void initState() {
    super.initState();
    _attachmentNotifier = ValueNotifier<File?>(null);
    formGroup = FormGroup({
      'title': FormControl<String>(
        validators: [Validators.required],
      ),
      'description': FormControl<String>(
        validators: [Validators.required],
      ),
    });
  }

  @override
  void dispose() {
    _attachmentNotifier.dispose();
    formGroup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(isLoadingProvider('createSupportTicket'));
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColor.pageBackgroundGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(10),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.grey1,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New ticket'.tr,
                        style: AppFont.font18W700Black,
                      ),
                      const Gap(4),
                      Text(
                        'Shake support hint'.tr,
                        style: AppFont.font12w500Grey2,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close_rounded, color: AppColor.black),
                ),
              ],
            ),
          ),
          Flexible(
            child: ReactiveForm(
              formGroup: formGroup,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          formControlName: 'title',
                          hintText: 'Ticket title'.tr,
                        ),
                        const Gap(12),
                        CustomTextField(
                          formControlName: 'description',
                          hintText: 'Ticket description'.tr,
                          maxLines: 5,
                          inputType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Attachment'.tr,
                    style: AppFont.font16W500Black.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(10),
                  ValueListenableBuilder<File?>(
                    valueListenable: _attachmentNotifier,
                    builder: (context, file, _) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: file == null
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: pickAttachment,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 44,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryDark,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.attach_file_rounded,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                        const Gap(12),
                                        Expanded(
                                          child: Text(
                                            'Add attachment'.tr,
                                            style: AppFont.font14W700Black,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColor.grey2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ImageOrSvg(
                                        file.path,
                                        isLocal: true,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        file.path.split(RegExp(r'[\\/]')).last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFont.font14W500Black,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: removeAttachment,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: AppColor.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: CustomFilledButton(
              text: 'Submit ticket'.tr,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : submitTicket,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RefundRequestSheet extends ConsumerStatefulWidget {
  const RefundRequestSheet({
    super.key,
    required this.orderId,
    required this.onPickImage,
    required this.onSubmit,
  });

  final String orderId;
  final Future<File?> Function() onPickImage;
  final Future<bool> Function(String reason, List<File> images) onSubmit;

  static const maxImages = 5;
  static const loadingKey = 'createRefundRequest';

  @override
  ConsumerState<RefundRequestSheet> createState() => _RefundRequestSheetState();
}

class _RefundRequestSheetState extends ConsumerState<RefundRequestSheet> {
  late final FormGroup _formGroup;
  late final ValueNotifier<List<File>> _images;

  @override
  void initState() {
    super.initState();
    _formGroup = FormGroup({
      'reason': FormControl<String>(
        validators: [Validators.required, Validators.minLength(3)],
      ),
    });
    _images = ValueNotifier<List<File>>(const []);
  }

  @override
  void dispose() {
    _images.dispose();
    _formGroup.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    if (_images.value.length >= RefundRequestSheet.maxImages) return;
    final file = await widget.onPickImage();
    if (file == null || !mounted) return;
    _images.value = [..._images.value, file];
  }

  void _removeImage(int index) {
    final next = [..._images.value]..removeAt(index);
    _images.value = next;
  }

  Future<void> _submit() async {
    if (!_formGroup.valid) {
      _formGroup.markAllAsTouched();
      return;
    }
    final reason =
        (_formGroup.control('reason').value as String? ?? '').trim();
    final ok = await widget.onSubmit(reason, _images.value);
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider(RefundRequestSheet.loadingKey));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ReactiveForm(
            formGroup: _formGroup,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColor.grey1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text(
                    'Request refund'.tr,
                    style: AppFont.font20W700Black,
                  ),
                  const Gap(8),
                  Text(
                    'Tell us why you need a refund and add supporting photos.'
                        .tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                  const Gap(18),
                  CustomTextField(
                    formControlName: 'reason',
                    hintText: 'Refund reason'.tr,
                    maxLines: 4,
                    inputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const Gap(16),
                  Text(
                    'Photos'.tr,
                    style: AppFont.font14W600Black,
                  ),
                  const Gap(10),
                  ValueListenableBuilder<List<File>>(
                    valueListenable: _images,
                    builder: (context, images, _) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < images.length; i++) ...[
                              if (i > 0) const Gap(10),
                              _ImageThumb(
                                file: images[i],
                                onRemove: isLoading
                                    ? null
                                    : () => _removeImage(i),
                              ),
                            ],
                            if (images.length < RefundRequestSheet.maxImages) ...[
                              if (images.isNotEmpty) const Gap(10),
                              _AddImageButton(
                                onTap: isLoading ? null : _addImage,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const Gap(22),
                  CustomFilledButton(
                    text: 'Submit refund request'.tr,
                    isLoading: isLoading,
                    width: MediaQuery.sizeOf(context).width - 48,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColor.pageBackgroundGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.grey1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColor.primary),
            const Gap(6),
            Text(
              'Add'.tr,
              style: AppFont.font12w500Grey2.copyWith(color: AppColor.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.file,
    this.onRemove,
  });

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: 84,
            height: 84,
            fit: BoxFit.cover,
          ),
        ),
        if (onRemove != null)
          PositionedDirectional(
            top: -6,
            end: -6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColor.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

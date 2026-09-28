import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';

class DeleteAccountConfirmationBottomSheet extends StatelessWidget {
  const DeleteAccountConfirmationBottomSheet({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteAccountConfirmationBottomSheet(
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColor.grey1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor.danger.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_outlined,
                  size: 48,
                  color: AppColor.danger,
                ),
              ),
              const Gap(24),
              Text(
                'Delete Account?'.tr,
                style: AppFont.font20W700Black,
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              Text(
                'Are you sure you want to delete your account? This action cannot be undone.'
                    .tr,
                style: AppFont.font14W500Black.copyWith(
                  color: AppColor.grey2,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: CustomOutlinedButton(
                      text: 'Cancel'.tr,
                      onPressed: () => Navigator.of(context).pop(),
                      textSize: 14,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: CustomFilledButton(
                      text: 'Delete account'.tr,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      textSize: 14,
                      color: AppColor.danger,
                      fontColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }
}

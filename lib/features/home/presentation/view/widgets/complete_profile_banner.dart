import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/features/profile/presentation/view/update_profile_view.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';

class CompleteProfileBanner extends ConsumerWidget {
  const CompleteProfileBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsToCompleteProfile = ref.watch(isNeedToCompleteProfile);

    if (!needsToCompleteProfile) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.primary.withAlpha(75),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.person_circle,
                  color: AppColor.primary,
                  size: 24,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile'.tr,
                      style: AppFont.font16W600Primary.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Add your information to get the best experience'.tr,
                      style: AppFont.subLabelTextField.copyWith(
                        fontSize: 12,
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          CustomFilledButton(
            onPressed: () {
              Get.to(() => const UpdateProfileView());
            },
            text: 'Complete Profile'.tr,
            color: AppColor.primary,
            fontColor: Colors.white,
            height: 44,
            radius: 8,
            isExpanded: true,
            widget: Icon(
              CupertinoIcons.arrow_right,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

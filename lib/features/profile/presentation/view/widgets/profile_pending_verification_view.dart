import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';

class ProfilePendingVerificationView extends StatelessWidget {
  const ProfilePendingVerificationView({
    super.key,
    required this.message,
    required this.pendingVerification,
    required this.onVerify,
  });

  final String message;
  final List<String> pendingVerification;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final channels = [
      if (pendingVerification.contains('email')) 'Email Address'.tr,
      if (pendingVerification.contains('phone')) 'Enter Phone Number'.tr,
    ].join(' • ');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: AppColor.primary,
            ),
            const Gap(16),
            Text(
              'Verify your account'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              message.tr,
              style: AppFont.font14W500Black.copyWith(
                color: AppColor.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (channels.isNotEmpty) ...[
              const Gap(8),
              Text(
                channels,
                style: AppFont.font14W600Black,
                textAlign: TextAlign.center,
              ),
            ],
            const Gap(24),
            CustomFilledButton(
              text: 'Verify'.tr,
              onPressed: onVerify,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';

Future<String?> showRoleSelectionBottomSheet() async {
  return await Get.bottomSheet<String>(
    Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.grey2.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),

          // Title
          Text(
            'Select Your Role'.tr,
            style: AppFont.font20W700Black.copyWith(
              fontSize: 24,
            ),
          ),
          const Gap(8),

          // Subtitle
          Text(
            'Choose how you want to use the app'.tr,
            style: AppFont.font14W500Black.copyWith(
              color: AppColor.grey2,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(32),

          // Customer option
          _RoleOptionCard(
            title: "I'm a Customer".tr,
            description: 'Browse and purchase products'.tr,
            icon: Icons.shopping_bag_outlined,
            onTap: () {
              Get.back(result: 'customer');
            },
          ),
          const Gap(16),

          // Vendor option
          _RoleOptionCard(
            title: "I'm a Vendor".tr,
            description: 'Sell your products'.tr,
            icon: Icons.store_outlined,
            onTap: () {
              Get.back(result: 'vendor');
            },
          ),
          const Gap(24),
        ],
      ),
    ),
    isDismissible: false,
    enableDrag: false,
  );
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.grey2.withAlpha(50),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColor.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.primary,
                size: 28,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFont.font16W600Black,
                  ),
                  const Gap(4),
                  Text(
                    description,
                    style: AppFont.font14W500Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColor.grey2,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

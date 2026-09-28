import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_image_circle.dart';
import '../../../../../config/app_font.dart';
import '../../../../../config/app_color.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../core/service/auth_service.dart';
import '../update_profile_view.dart';

class ProfileHeaderTile extends ConsumerWidget {
  const ProfileHeaderTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider) ?? dataManager.getUser();
    
    final topPadding = MediaQuery.of(context).padding.top;
    final imageUrl = user?.image ?? "";
    final userName = user?.name ?? "";
    final userPhone = user?.phone ?? "";
    final editText = "Edit".tr;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Gap(topPadding),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.grey1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CustomImageCircle(image: imageUrl),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppFont.font18W700Black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userPhone,
                          textDirection: TextDirection.ltr,
                          style: AppFont.font12w500Grey2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  CustomFilledButton(
                    onPressed: () => Get.to(() => const UpdateProfileView()),
                    text: editText,
                    width: 110,
                    height: 45,
                    color: AppColor.primary2,
                    fontColor: AppColor.black,
                    isExpanded: true,
                    widget: FaIcon(
                      FontAwesomeIcons.userPen,
                      color: AppColor.black,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
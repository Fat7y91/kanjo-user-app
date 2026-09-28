import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';

import '../../../../config/app_font.dart';
import '../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../ui/ui.dart';
import '../../../vendor/data/models/vendor_model.dart';

class PharmacyStoreChatScreen extends StatelessWidget {
  const PharmacyStoreChatScreen({super.key, required this.vendor});

  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _ChatAppBar(vendor: vendor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Center(
                  child: Text(
                    'Pharmacy chat today'.tr,
                    style: AppFont.font12w400Black.copyWith(
                      color: AppColor.textGrey,
                    ),
                  ),
                ),
                const Gap(16),
                _PharmacyBubbleRow(
                  avatarUrl: vendor.imageUrl,
                  child: Text(
                    'Pharmacy chat msg pharmacy 1'.tr,
                    style: AppFont.font15W500Black.copyWith(height: 1.35),
                  ),
                ),
                const Gap(12),
                _UserBubbleColumn(
                  timeText: '10:35 Am',
                  child: Text(
                    'Pharmacy chat msg user 1'.tr,
                    style: AppFont.font15W500White.copyWith(height: 1.35),
                  ),
                ),
                const Gap(12),
                _PharmacyBubbleRow(
                  avatarUrl: vendor.imageUrl,
                  child: Text(
                    'Pharmacy chat msg pharmacy 2'.tr,
                    style: AppFont.font15W500Black.copyWith(height: 1.35),
                  ),
                ),
                const Gap(12),
                _PharmacyBubbleRow(
                  avatarUrl: vendor.imageUrl,
                  child: _OrderProposalCard(
                    title: 'Pharmacy chat order proposal'.tr,
                    onYes: () => UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
                    onNo: () => UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
            child: _MessageComposer(),
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({required this.vendor});

  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final avatarUrl = vendor.logoUrl?.isNotEmpty == true
        ? vendor.logoUrl
        : vendor.imageUrl;

    return Material(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, top + 6, 0, 12),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: () => Get.back(closeOverlays: true),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: AppColor.black,
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.grey1,
                  child: ClipOval(
                    child: ImageOrSvg(
                      avatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      pickImageOnNull: true,
                      assetImageOnNull: AppAssets.logoOnly,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendor.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font16W400Black.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pharmacy chat active'.tr,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.textBodySecondary,
                        ),
                      ),
                      const Gap(6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColor.green1,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
              icon: Icon(Icons.phone_outlined, color: AppColor.black, size: 24),
            ),
            const Gap(20)
          ],
        ),
      ),
    );
  }
}

class _PharmacyBubbleRow extends StatelessWidget {
  const _PharmacyBubbleRow({
    required this.avatarUrl,
    required this.child,
  });

  final String avatarUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.width*0.7),
            decoration: BoxDecoration(
              color: AppColor.checkoutBorder,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: child,
            ),
          ),
        ),
        const Gap(8),
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColor.grey1,
          child: ClipOval(
            child: ImageOrSvg(
              avatarUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              pickImageOnNull: true,
              assetImageOnNull: AppAssets.logoOnly,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserBubbleColumn extends StatelessWidget {
  const _UserBubbleColumn({
    required this.child,
    required this.timeText,
  });

  final Widget child;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            constraints: BoxConstraints(maxWidth: context.width*0.7),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: child,
            ),
          ),
        ),
        const Gap(4),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Text(
            timeText,
            style: AppFont.font12w400Black.copyWith(color: AppColor.textGrey),
          ),
        ),
      ],
    );
  }
}

class _OrderProposalCard extends StatelessWidget {
  const _OrderProposalCard({
    required this.title,
    required this.onYes,
    required this.onNo,
  });

  final String title;
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFont.font15W500Black.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onYes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.onAccentSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('Pharmacy chat yes'.tr),
              ),
            ),
            const Gap(10),
            Expanded(
              child: OutlinedButton(
                onPressed: onNo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  side: const BorderSide(color: AppColor.primary, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('Pharmacy chat no'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageComposer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Material(
          color: AppColor.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                AppAssets.paperPlane,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColor.onAccentSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.cartCardBorder,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
                    icon: Icon(Icons.attach_file, color: AppColor.textGrey, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: 'Pharmacy chat input hint'.tr,
                        hintStyle: AppFont.hintTextField,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        UIHelper.showGlobalSnackBar(text: 'Coming soon'.tr),
                    icon: Icon(Icons.mic_none_rounded,
                        color: AppColor.textGrey, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

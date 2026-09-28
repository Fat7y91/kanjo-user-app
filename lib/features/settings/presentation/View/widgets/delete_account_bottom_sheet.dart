import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/auth/domain/use_cases/login_user_use_case.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/main.dart';
import '../../../../../config/app_font.dart';
import '../../../../../config/app_color.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';

class GeneralBottomSheet extends StatelessWidget {
  final bool isError;
  final String title;
  final String? description;
  final void Function()? onPressed;

  const GeneralBottomSheet({
    super.key,
    required this.title,
    this.isError = true,
    this.description,
    this.onPressed,
  });

  static void show(
    BuildContext context,
    String title, {
    String? description,
    bool isError = true,
    void Function()? onPressed,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GeneralBottomSheet(
        title: title,
        description: description,
        isError: isError,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColor.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Image.asset(
              AppAssets.error,
              height: 140,
              width: 140,
            ),
            Gap(30),
            Text(
              'Are You Delete Account'.tr,
              style: AppFont.font20W700Black,
              textAlign: TextAlign.center,
            ),
            Gap(12),
            if(description!=null)
            Text(
              description!,
              style: AppFont.font14W500Black,
              textAlign: TextAlign.center,
            ),
            Gap(24),
            CustomFilledButton(
              text: 'Confirm'.tr,
              fontColor: Colors.white,
              color: AppColor.primary,
              onPressed: onPressed),
            Gap(10.h),
          ],
        ),
      ),
    );
  }
}

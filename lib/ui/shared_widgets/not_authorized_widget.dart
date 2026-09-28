import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_font.dart';
import '../../features/auth/presentation/view/login_page.dart';
import 'custom_filled_button.dart';
import 'not_found_widget.dart';

class NotAuthorizedWidget extends StatelessWidget {
  const NotAuthorizedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NotFoundWidget(
          title: "Please login first to proceed".tr,
          haveIcon: true,
          style: AppFont.font16W600Black,
        ),
        CustomFilledButton(
          width: 200,
          text: "Login".tr,
          onPressed: () => Get.offAll(() => LoginPage()),
        )
      ],
    );
  }
}
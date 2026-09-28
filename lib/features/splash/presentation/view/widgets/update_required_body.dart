import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/remote_config_service.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/logo_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';

class UpdateRequiredBody extends StatelessWidget {
  const UpdateRequiredBody({
    super.key,
    required this.storeLink,
  });

  final String storeLink;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(),
            const Gap(32),
            Text(
              'Update required'.tr,
              style: AppFont.font24w600Black,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Update required message'.tr,
              style: AppFont.font14W500Black,
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            CustomFilledButton(
              text: 'Update'.tr,
              color: AppColor.primary,
              onPressed: () async {
                final link = storeLink.isNotEmpty
                    ? storeLink
                    : getIt<RemoteConfigService>().storeLink;
                if (link.isNotEmpty && await canLaunchUrl(Uri.parse(link))) {
                  await launchUrlString(
                    link,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

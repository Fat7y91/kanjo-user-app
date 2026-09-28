import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import '../../config/app_assets.dart';
import '../../config/app_color.dart';
import '../../features/offline/widgets/reload_button.dart';
import '../../helper/responsive.dart';

class NotFoundWidget extends StatelessWidget {
  const NotFoundWidget({
    required this.title,
    this.message,
    this.onTryAgain,
    this.haveIcon = false,
    this.center = true,
    super.key,
    this.icon,
    this.style,
  });

  final String title;
  final bool haveIcon;
  final String? message;
  final TextStyle? style;
  final bool center;
  final VoidCallback? onTryAgain;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final message = this.message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment:
              center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (haveIcon) ...[
              if (icon != null)
                Center(
                  child: Image.asset(
                    icon!,
                    height: 100.h,
                    color: AppColor.primary,
                  ),
                ),
              if (icon == null)
                Center(
                    child: SvgPicture.asset(
                  AppAssets.folderOpen,
                  height: 100.h,
                  colorFilter:
                      ColorFilter.mode(AppColor.primary, BlendMode.srcIn),
                )),
              Gap(8.h),
            ],
            Text(title,
                textAlign: TextAlign.center,
                style: style ?? AppFont.font20W700Primary),
            if (message != null)
              const SizedBox(
                height: 16,
              ),
            if (message != null)
              Text(
                message,
                textAlign: TextAlign.center,
                style: style ?? AppFont.font16W700Primary,
              ),
            if (onTryAgain != null)
              SizedBox(
                height: 8.h,
              ),
            if (onTryAgain != null)
              ReloadButton(
                onTap: onTryAgain,
                size: 25,
                color: AppColor.primary,
              ),
          ],
        ),
      ),
    );
  }
}

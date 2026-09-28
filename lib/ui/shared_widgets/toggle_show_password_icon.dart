import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/app_color.dart';
import '../../helper/responsive.dart';

class ToggleShowPasswordButton extends StatelessWidget {
  const ToggleShowPasswordButton(
      {super.key, required this.onTap, required this.showPass});

  final void Function() onTap;
  final bool showPass;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        showPass ? "assets/base/eye-crossed.svg" : "assets/base/eye.svg",
        color: showPass ? AppColor.disabled : AppColor.primary,
        height: 15.57.h,
        width: 20.w,
      ),
    );
  }
}

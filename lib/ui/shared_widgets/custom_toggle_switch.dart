import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../config/app_font.dart';
import '../../helper/responsive.dart';

class CustomToggleSwitch extends StatelessWidget {
  const CustomToggleSwitch(
      {super.key,
      this.width,
      required this.labels,
      this.onToggle,
      this.index = 0});

  final double? width;
  final ValueChanged<int?>? onToggle;
  final List<String> labels;
  final int index;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return ToggleSwitch(
      minHeight: 38.0,
      cornerRadius: 20.0,
      minWidth: width ?? double.infinity,
      activeFgColor: AppColor.white,
      activeBgColor: const [
        AppColor.primary,
        AppColor.primary,
      ],
      customTextStyles: [
        AppFont.font16W600nullColor,
        AppFont.font16W600nullColor,
      ],
      fontSize: 16,
      initialLabelIndex: index,
      totalSwitches: labels.length,
      labels: labels,
      radiusStyle: true,
      inactiveBgColor: AppColor.white,
      onToggle: onToggle,
      inactiveFgColor: AppColor.grey2,
    );
  }
}

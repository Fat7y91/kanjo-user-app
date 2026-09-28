import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../config/app_color.dart';
import '../../config/app_font.dart';
import '../../helper/responsive.dart';
import 'loading_widget.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton(
      {super.key,
      this.text,
      this.height,
      this.color,
      this.textColor,
      this.textSize,
      this.isLoading = false,
      this.isExpanded = false,
      this.onPressed,
      this.radius,
      this.padding,
      this.ignorePressOnNotValid = false,
      this.width,
      this.widget,
      this.isValid = true});

  final double? height;
  final double? radius;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final Widget? widget;
  final Color? color;
  final Color? textColor;
  final bool isValid;

  final String? text;
  final EdgeInsetsGeometry? padding;
  final void Function()? onPressed;
  final bool ignorePressOnNotValid;

  final double? textSize;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: padding,
        fixedSize: Size(width ?? 1.sw, height ?? 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius??25),
        ),
        side: BorderSide(
            width: 2.0,
            color: isValid
                ? color != null
                    ? color!
                    : AppColor.primary
                : AppColor.disabled),
      ),
      onPressed:
          isLoading || (ignorePressOnNotValid && !isValid) ? null : onPressed,
      child: isLoading
          ? LoadingWidget(
              color: AppColor.white,
            )
          : widget != null && text != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text!,
                      style: AppFont.font20W700Primary.copyWith(
                          overflow: TextOverflow.ellipsis,
                          fontSize: textSize ?? 18,
                          color: textColor ?? AppColor.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    isExpanded ? const Spacer() : Gap(5.w),
                    widget!
                  ],
                )
              : widget != null
                  ? widget!
                  : Text(
                      text!,
                      style: AppFont.font20W700Primary.copyWith(
                          overflow: TextOverflow.ellipsis,
                          fontSize: textSize ?? 18,
                          color: textColor ?? AppColor.primary,
                          fontWeight: FontWeight.w400),
                    ),
    );
  }
}

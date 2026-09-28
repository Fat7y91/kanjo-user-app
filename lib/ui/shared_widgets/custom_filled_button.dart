import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../config/app_font.dart';
import '../../helper/responsive.dart';
import 'loading_widget.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    this.text,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding = 20,
    this.verticalPadding = 12,
    this.color,
    this.gradient,
    this.fontColor,
    this.height,
    this.radius,
    this.onPressed,
    this.textSize,
    this.width,
    this.widget,
    this.fontWeight,
    this.ignorePressOnNotValid = false,
    this.isValid = true,
  });

  final bool isLoading;

  final Color? color;
  final Gradient? gradient;
  final Color? fontColor;
  final String? text;
  final Widget? widget;
  final void Function()? onPressed;
  final bool isValid;
  final int padding;
  final int verticalPadding;
  final bool isExpanded;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final double? textSize;
  final double? radius;
  final bool ignorePressOnNotValid;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final isDisabled = isLoading || (ignorePressOnNotValid && !isValid);
    final borderRadius = BorderRadius.circular(radius ?? 25);
    final buttonSize = Size(width ?? 1.sw, height ?? 48);
    final content = isLoading
        ? LoadingWidget(
            color: AppColor.white,
          )
        : widget != null && text != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text!,
                    style: AppFont.font20W600White.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: fontColor ?? AppColor.white,
                        fontSize: textSize ?? 16,
                        fontWeight: fontWeight ?? FontWeight.w600),
                  ),
                  isExpanded ? const Spacer() : Gap(5),
                  widget!
                ],
              )
            : widget != null
                ? widget!
                : Text(
                    text!,
                    style: AppFont.font20W600White.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: fontColor ?? AppColor.white,
                        fontSize: textSize ?? 16,
                        fontWeight: fontWeight ?? FontWeight.w600),
                  );

    if (gradient != null) {
      return Opacity(
        opacity: isValid ? 1 : 0.6,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: isDisabled ? null : onPressed,
            child: Ink(
              width: buttonSize.width,
              height: buttonSize.height,
              padding: EdgeInsets.symmetric(
                horizontal: padding.toDouble(),
                vertical: verticalPadding.toDouble(),
              ),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: borderRadius,
              ),
              child: Center(child: content),
            ),
          ),
        ),
      );
    }

    return FilledButton(
      style: ButtonStyle(
          fixedSize: WidgetStateProperty.all(buttonSize),
          backgroundColor: WidgetStateProperty.all(
              !isValid ? AppColor.disabled : color ?? AppColor.primary),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(
              horizontal: padding.toDouble(), vertical: verticalPadding.toDouble())),
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius))),
      onPressed: isDisabled ? null : onPressed,
      child: content,
    );
  }
}


class CustomFilteredButton extends StatelessWidget {
  final Widget widget;
  final Color color;
  final VoidCallback onTap;

  const CustomFilteredButton({super.key, required this.onTap, required this.widget, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(80)),
                color: color,
              ),
              child: widget),
        ),
      ),
    );
  }
}

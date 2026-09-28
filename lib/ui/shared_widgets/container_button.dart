import 'package:flutter/material.dart';
import 'package:heraj/config/app_color.dart';

class ContainerButton extends StatelessWidget {
  final void Function()? onTap;
  final Widget? widget;
  final IconData? icon;
  final double? size;
  final double? radius;
  final double? iconSize;
  final Color? color;
  final Color? iconColor;
  final bool isCircle;
  final bool isValidOrLoading;

  const ContainerButton({
    super.key,
    this.onTap,
    this.icon,
    this.size,
    this.color,
    this.widget,
    this.radius,
    this.iconColor,
    this.isCircle = false,
    this.isValidOrLoading = false, this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isValidOrLoading ? () {} : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCircle ? 100 : radius ?? 8),
        child: Container(
          height: size ?? 40,
          width: size ?? 40,
          decoration: BoxDecoration(
              color: isValidOrLoading
                  ? (color ?? Colors.green.withOpacity(.2)).withAlpha(100)
                  : (color ?? AppColor.grey1.withAlpha(100)),
              borderRadius: BorderRadius.circular(isCircle ? 100 : radius ?? 8),
              border: Border.all(
                  color: color == Colors.transparent
                      ? Colors.transparent
                      : color ?? Colors.green.withOpacity(.2))),
          child: Center(
              child: widget ??
                  Icon(
                    icon,
                    size: iconSize?? 20,
                    color: iconColor ?? AppColor.black,
                  )),
        ),
      ),
    );
  }
}

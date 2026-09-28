import 'package:heraj/helper/responsive.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/config/app_color.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
    this.finalItem = false,
    this.trailing,
    this.showArrow = true,
  });

  final String title;
  final bool finalItem;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 12;
    final itemHeight = 50;
    final iconSize = 22.0;
    final gapWidth = 20;
    final iconColor = color ?? AppColor.black;
    final arrowColor = color == AppColor.danger ? AppColor.danger : AppColor.grey2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding.toDouble()),
          height: itemHeight.toDouble(),
          child: Row(
            children: [
              Container(
                height: iconSize * 1.5,
                width: iconSize * 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColor.grey1.withAlpha(100)
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              Gap(gapWidth.toDouble()),
              Expanded(
                child: Text(
                  title,
                  style: AppFont.font14W700Black.copyWith(
                    color: color == AppColor.danger ? AppColor.danger : color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const Gap(8),
                trailing!,
              ],
              if (showArrow && trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: arrowColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

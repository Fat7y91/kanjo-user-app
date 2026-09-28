import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../config/app_color.dart';
import '../../../../helper/responsive.dart';

class ReloadButton extends StatelessWidget {
  const ReloadButton(
      {super.key, this.onTap, this.size = 18, this.color = AppColor.primary,this.icon = FontAwesomeIcons.rotateRight});

  final Function()? onTap;
  final double size;
  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return FloatingActionButton(
      mini: true,
      onPressed: onTap,
      child: Center(
        child: FaIcon(
          icon,
          size: size.h,
          color: color,
        ),
      ),
    );
  }
}

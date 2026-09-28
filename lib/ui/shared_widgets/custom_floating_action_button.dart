import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../config/app_color.dart';
import '../../helper/responsive.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton(
      {super.key, required this.onPressed, this.iconData});

  final void Function() onPressed;
  final FaIconData? iconData;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return FloatingActionButton(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: onPressed,
      child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: FaIcon(iconData ?? FontAwesomeIcons.plus)),
    );
  }
}

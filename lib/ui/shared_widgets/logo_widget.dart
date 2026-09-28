import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_assets.dart';
import '../../helper/responsive.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    this.colorText,
    this.colorImage,
    super.key,
  });

  final Color? colorText;
  final Color? colorImage;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Image.asset(
      AppAssets.logo,
      height: 200,
    );
  }
}

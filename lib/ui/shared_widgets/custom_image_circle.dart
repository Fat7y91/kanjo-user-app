import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import '../../config/app_color.dart';

class CustomImageCircle extends StatelessWidget {
  const CustomImageCircle({
    super.key,
    required this.image,
    this.radius = 16,
    this.isLocal = false,
  });

  final String image;
  final num radius;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius.r + 4.r,
      backgroundColor: AppColor.primary,
      child: CircleAvatar(
        radius: radius.r + 2.r,
        backgroundColor: AppColor.white,
        child: ClipOval(
          child: ImageOrSvg(
            image,
            fit: BoxFit.cover,
            width: (radius * 2).r,
            height: (radius * 2).r,
            isLocal: isLocal,
            pickImageOnNull: true,
          ),
        ),
      ),
    );
  }
}

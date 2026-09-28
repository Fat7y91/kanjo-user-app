import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/responsive.dart';

class BackIcon extends StatelessWidget {
  const BackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Container(
        height: 43.h,
        width: 43.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_outlined,
          size: 17.12.h,
          color: Colors.black,
        ),
      ),
    );
  }
}

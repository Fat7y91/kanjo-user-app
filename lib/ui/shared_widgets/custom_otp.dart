import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../config/app_color.dart';
import '../../helper/responsive.dart';

class CustomOTP extends StatelessWidget {
  const CustomOTP({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.controller,
  });

  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinCodeTextField(
        controller: controller,
        autoDisposeControllers: controller == null,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        pinTheme: PinTheme(
          borderRadius: BorderRadius.circular(20),
          shape: PinCodeFieldShape.box,
          selectedFillColor: Colors.transparent,
          inactiveFillColor: Colors.transparent,
          activeFillColor: Colors.white.withAlpha(80),
          activeColor: AppColor.primary,
          inactiveColor: AppColor.grey2,
          selectedColor: AppColor.primary,
          fieldWidth: 50,
          fieldHeight: 60,
          borderWidth: 0,
        ),
        onCompleted: onCompleted,
        onChanged: onChanged,
        appContext: context,
      ),
    );
  }
}

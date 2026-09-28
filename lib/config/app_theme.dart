import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData getLightTheme() {
  return FlexThemeData.light(
      scaffoldBackground: Color(0xffF4F4F4),
      appBarStyle: FlexAppBarStyle.background,
      colors: const FlexSchemeColor(
        primary: AppColor.primary,
        secondary: Colors.white,
      ),
      scheme: FlexScheme.greenM3,
      fontFamily: "co_headline",
      primary: AppColor.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.primary,
      ));
}

ThemeData getDarkTheme() {
  return FlexThemeData.dark(
      scaffoldBackground: const Color(0xff151518),
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      colors: const FlexSchemeColor(
        primary: AppColor.primary,
        secondary: Colors.white,
      ),
      scheme: FlexScheme.greenM3,
      fontFamily: "co_headline",
      primary: AppColor.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.primary,
      )
      // textButtonTheme: TextButtonThemeData(
      //   style: TextButton.styleFrom(foregroundColor: mainColor),
      // ),
      // colorScheme: ColorScheme.dark(
      //   primary: mainColor,
      //   secondary: mainColor,
      // )
      );
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class AppColor {
  static Color get white =>
      Get.isDarkMode ? const Color(0xff151518) : Colors.white;

  static Color get nearlyWhite =>
      Get.isDarkMode ? const Color(0xff283046) : Colors.white;

  static Color get grey3 =>
      Get.isDarkMode ? const Color(0xff777777) : Colors.white;

  static Color get grey_3 =>
      Get.isDarkMode ? const Color(0xff929898) : const Color(0xffD9D9D9);

  static Color get gray_3 =>
      Get.isDarkMode ? const Color(0xff777777) : const Color(0xffD9D9D9);

  static Color get whiteOrGrey =>
      Get.isDarkMode ? const Color(0xff929898) : Colors.white;

  static Color get black =>
      Get.isDarkMode ? Colors.white : const Color(0xff161d31);
  static const Color green = Color(0xff00A991);
  static const Color green1 = Color(0xff29CD00);
  static const Color danger = Color(0xffE34E00);
  static Color danger2 = Get.isDarkMode ? Colors.red.shade900 : Colors.red;
  static const Color orange = Colors.orange;
  static const Color gold = Color(0xFFF2C71C);
  static const Color primary = Color(0xff9810FA);
  static const Color primary2 = Color(0xff6E11B0);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color pageBackgroundGrey = Color(0xFFF6F6F6);
  static const Color cartCardBorder = Color(0xFFEFEFEF);
  static const Color checkoutBorder = Color(0xFFE6E6E6);
  static const Color radioBorderGrey = Color(0xFFADADAD);
  static const Color gray900 = Color(0xFF161616);
  static const Color priceStrikeRed = Color(0xFFC92127);
  static const Color textGrey = Color(0xFF949494);
  static const Color textDark = Color(0xFF111111);
  static const Color textBodySecondary = Color(0xFF666666);
  static const Color textBodyTertiary = Color(0xFF999999);
  static const Color softShadowBase = Color(0xFF23272F);
  static const Color onAccentSurface = Color(0xFFFFFFFF);
  static const Color guestOrange = Color(0xFFF47621);
  static Color primaryWhite =
      Get.isDarkMode ? const Color(0xff161d31) : const Color(0xffF0EBEB);
  static const Color primary3 = Color(0xffE9E1E1);
  static const Color primary4 = Color(0xff241180);
  static const Color primary5 = Color(0xffB9C3CF);
  static const Color mineShaft = Color(0xff222222);

  static Color get shipmentTileColor =>
      Get.isDarkMode ? const Color(0xff2f2f2f) : Colors.white;

  static const Color primaryDark = Color(0xFFF2ECFF);

  static Color get backGround =>
      Get.isDarkMode ? const Color(0xff303030) : const Color(0xffEAEAEA);

  static Color get disabled =>
      Get.isDarkMode ? const Color(0xff9EACAD) : const Color(0xffC0CDCE);

  static Color get grey2 =>
      Get.isDarkMode ? const Color(0xff929898) : const Color(0xff656969);

  static const Color grey1 = Color(0xffd0d9e5);
  static const unselectedNavBar = Color(0xff707070);

  static BoxShadow defaultShadow = BoxShadow(
      color: Colors.black.withAlpha(40),
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0);

  static BoxShadow lightShadow = BoxShadow(
      color: Colors.grey.withAlpha(120),
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0);

  static BoxShadow defaultPrimaryShadow = BoxShadow(
    color: AppColor.primary.withAlpha(50),
    blurRadius: 6,
    spreadRadius: 5,
    offset: const Offset(0, 3),
  );

  static LinearGradient defaultPrimaryGradient = LinearGradient(
    colors: [primary, primary2],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  static LinearGradient goldGradient = LinearGradient(
    colors: [gold, primary2],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  static LinearGradient defaultWhiteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withAlpha(245),
      Colors.white.withAlpha(70),
      Colors.white.withAlpha(38),
      Colors.white.withAlpha(240),
    ],
    stops: const [0.0, 0.30, 0.72, 1.0],
  );

  static LinearGradient defaultPrimaryGradient2 = LinearGradient(
    colors: [
      Color(0xff960ff7),
      Color(0xff850fd9),
      Color(0xff6e12b0),
    ],
    stops: [0, 0.9, 1],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  static LinearGradient reversedPrimaryGradient = LinearGradient(
    colors: [
      Color(0xff6e12b0),
      Color(0xff850fd9),
      Color(0xff960ff7),
    ],
    stops: [0, 0.9, 1],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  static final ImageFilter defaultImageFilter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
}

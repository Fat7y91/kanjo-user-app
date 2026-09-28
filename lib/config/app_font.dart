import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_color.dart';
export 'app_color.dart';

abstract class AppFont {
  static TextStyle get _style => const TextStyle(fontFamily: "co_headline");

  static TextStyle get hintTextField => _style.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColor.black.withOpacity(0.44),
      );

  static TextStyle get font16W400Black => _style.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font15W500Black => _style.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColor.black,
      );

  static TextStyle get font15W500White => _style.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColor.white,
      );

  static TextStyle get font12w400Black => _style.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font24w600Black => _style.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColor.black,
      );

  static TextStyle get font48W500PrimaryBlue => _style.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w500,
        color: AppColor.primary,
      );

  static TextStyle get labelTextField => _style.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font25W700Primary => _style.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      );

  static TextStyle get font25W700Black => _style.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: AppColor.black,
      );

  static TextStyle get font13W400Black => _style.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font10w400Green => _style.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColor.green,
      );

  static TextStyle get font10w400Black => _style.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font10w400Primary => _style.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColor.primary,
      );

  static TextStyle get font10w400White => _style.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColor.white,
      );

  static TextStyle get font13w400Green => _style.copyWith(
        fontSize: 13.w,
        fontWeight: FontWeight.w400,
        color: AppColor.green,
      );

  static TextStyle get font15w400Green => _style.copyWith(
        fontSize: 15.w,
        fontWeight: FontWeight.w400,
        color: AppColor.green,
      );

  static TextStyle get subLabelTextField => _style.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      );

  static TextStyle get subLabelBlackTextField => _style.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get buttonText =>
      _style.copyWith(fontSize: 20, color: Colors.white);

  static TextStyle get font20W600Black => _style.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColor.black,
      );

  static TextStyle get font22W600Primary => _style.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColor.primary,
      );

  static TextStyle get font22W600Black => _style.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColor.black,
      );

  static TextStyle get font18W700Black => _style.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      );

  static TextStyle get font18W700Priamry => _style.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColor.primary,
      );

  static TextStyle get font35BoldPrimary => _style.copyWith(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      );

  static TextStyle get font30W600Black => _style.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      );

  static TextStyle get font20W700Black => _style.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      );

  static TextStyle get font20W700White => _style.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColor.white,
      );

  static TextStyle get font20W700NearlyWhite => _style.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColor.nearlyWhite,
      );

  static TextStyle get font18W700NearlyWhite => _style.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColor.nearlyWhite,
      );

  static TextStyle get font20W700Primary => _style.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColor.primary,
      );

  static TextStyle get textFiled => _style.copyWith(
        fontSize: 14,
        color: AppColor.primary,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get font12Regular => _style.copyWith(
        fontSize: 12,
      );

  static TextStyle get font13W600Grey1 => _style.copyWith(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.grey1);

  static TextStyle get font14W600Grey1 => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.grey1);

  static TextStyle get font12W400Grey1 => _style.copyWith(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.grey1);

  static TextStyle get font12W400white => _style.copyWith(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white);

  static TextStyle get font11W400Grey1 => _style.copyWith(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.grey1);

  static TextStyle get font11W400Grey2 => _style.copyWith(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColor.grey2);

  static TextStyle get font10W400Grey1 => _style.copyWith(
      fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.grey1);

  static TextStyle get font12W600Grey1 => _style.copyWith(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.grey1);

  static TextStyle get font16W600Grey1 => _style.copyWith(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColor.grey1);

  static TextStyle get font13W600Grey2 => _style.copyWith(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.grey2);

  static TextStyle get font13W600Primary => _style.copyWith(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.primary);

  static TextStyle get font16W600Gray2 => _style.copyWith(
        fontSize: 16,
        color: AppColor.grey2,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get font16W500Black => _style.copyWith(
        fontSize: 16,
        color: AppColor.black,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get font12w500Grey2 => _style.copyWith(
        fontSize: 12,
        color: AppColor.grey2,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get font10W600White => _style.copyWith(
        fontSize: 10,
        color: AppColor.grey1,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get font16W700Black => _style.copyWith(
        fontSize: 16,
        color: AppColor.black,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get font16W900Black => _style.copyWith(
        fontSize: 16,
        color: AppColor.black,
        fontWeight: FontWeight.w900,
      );

  static TextStyle get font16W700Primary => _style.copyWith(
      fontSize: 16, color: AppColor.primary, fontWeight: FontWeight.w700);

  static TextStyle get font16W900Primary => _style.copyWith(
      fontSize: 16, color: AppColor.primary, fontWeight: FontWeight.w900);

  static TextStyle get font16W600Black => _style.copyWith(
        fontSize: 16,
        color: AppColor.black,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get font20W600White => _style.copyWith(
        fontSize: 20,
        color: AppColor.white,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get font12W600White => _style.copyWith(
      fontSize: 12, color: AppColor.white, fontWeight: FontWeight.w600);

  static TextStyle get font12W600Gold => _style.copyWith(
      fontSize: 12, color: AppColor.orange, fontWeight: FontWeight.w600);

  static TextStyle get font12W600NearlyWhite => _style.copyWith(
      fontSize: 12,
      color: AppColor.nearlyWhite,
      fontWeight: FontWeight.w600);

  static TextStyle get font12W600Grey2 => _style.copyWith(
      fontSize: 12, color: AppColor.grey2, fontWeight: FontWeight.w600);

  static TextStyle get font12W600Primary => _style.copyWith(
      fontSize: 12, color: AppColor.primary, fontWeight: FontWeight.w600);

  static TextStyle get font12W600Green => _style.copyWith(
      fontSize: 12, color: AppColor.green, fontWeight: FontWeight.w600);

  static TextStyle get font12W700Primary => _style.copyWith(
      fontSize: 12, color: AppColor.primary, fontWeight: FontWeight.w700);

  static TextStyle get font12W600Black => _style.copyWith(
      fontSize: 12, color: AppColor.black, fontWeight: FontWeight.w600);

  static TextStyle get font14W600Primary => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.primary);

  static TextStyle get font14W600Primary4 => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.primary4);

  static TextStyle get font14W600Green => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.green);

  static TextStyle get font14W600Black => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.black);

  static TextStyle get font14W700Black => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w700, color: AppColor.black);

  static TextStyle get font14W700Danger => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w700, color: AppColor.danger);

  static TextStyle get font14W500Grey2 => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.grey2);

  static TextStyle get font14W500Black => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.black);

  static TextStyle get font14W500White => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.white);

  static TextStyle get font14W700White => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w700, color: AppColor.white);

  static TextStyle get font14W600Grey2 => _style.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.grey2);

  static TextStyle get font15W700Black => _style.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      );

  static TextStyle get font15W400Black => _style.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColor.black,
      );

  static TextStyle get font16W600Primary => _style.copyWith(
      fontSize: 16, color: AppColor.primary, fontWeight: FontWeight.w600);

  static TextStyle get font16W600nullColor =>
      _style.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get font14W600nullColor =>
      _style.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get font14W600White =>
      _style.copyWith(fontSize: 14, fontWeight: FontWeight.w600,color: AppColor.white);

  static TextStyle get font16W600NearlyWhite => _style.copyWith(
      fontSize: 16,
      color: AppColor.nearlyWhite,
      fontWeight: FontWeight.w600);

  static TextStyle get font15W600NearlyWhite => _style.copyWith(
      fontSize: 15,
      color: AppColor.nearlyWhite,
      fontWeight: FontWeight.w600);
}

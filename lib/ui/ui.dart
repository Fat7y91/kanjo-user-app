import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:heraj/config/api_path.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../config/app_font.dart';

abstract class UIHelper {
  UIHelper._();

  static Future<void> copy(String text, BuildContext context, {String? key}) {
    return Clipboard.setData(ClipboardData(text: text)).then((value) {
      showSnackBar('Copied'.tr + (key == null ? '' : ' [ $key ]'), context);
    });
  }

  static Future<void> phoneCall(String phone, {String? key}) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {}
  }

  static Widget shareWidget({int? carId}) {
    return InkWell(
      onTap: () {
        SharePlus.instance
            .share(ShareParams(text: '${ApiPath.sharePath}$carId'));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Icon(
          Icons.share,
          size: 18,
        ),
      ),
    );
  }

  static Future<DateTime?> pickDate({
    required BuildContext context,
    required DateTime? date,
  }) async {
    final dateTime = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      dateFormat: "dd-MMMM-yyyy",
    );

    return dateTime;
  }

  static void showSnackBar(String text, BuildContext context,
      {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        showCloseIcon: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Text(
          text,
          style: TextStyle(color: textColor),
        )));
  }

  static SystemUiOverlayStyle getSystemOverlayStyle([bool? isDark]) {
    final darkMode = isDark ?? Get.isDarkMode;

    if (kIsWeb) {
      final brightness = darkMode ? Brightness.dark : Brightness.light;
      return SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarColor: Colors.transparent,
      );
    }

    SystemUiOverlayStyle? overlay;

    if (Platform.isAndroid) {
      final brightness = !darkMode ? Brightness.dark : Brightness.light;
      // Edge-to-edge is set once in main(); calling it here breaks IME on rebuild.
      overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: brightness,
      );
    } else {
      final brightness = darkMode ? Brightness.dark : Brightness.light;
      overlay = SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarColor: Colors.transparent,
      );
    }
    return overlay;
  }

  static Future showAlert(
    String msg, {
    BuildContext? context,
    DialogType type = DialogType.success,
  }) {
    return AwesomeDialog(
      btnOkColor: Get.theme.primaryColor,
      context: context ?? Get.context!,
      dialogType: type,
      animType: AnimType.topSlide,
      title: msg,
      btnOkText: 'done'.tr,
      btnOkOnPress: () {},
    ).show();
  }

  static SliverGridDelegateWithFixedCrossAxisCount
      getResponsiveSliverGridDelegate(BuildContext context) {
    final shortestSize = context.mediaQuerySize.shortestSide;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: shortestSize < 300 ? 1 : max(context.width ~/ 385 + 1, 2),
      crossAxisSpacing: 11.w,
      mainAxisSpacing: 11.h,
      childAspectRatio: 1.1843971631,
    );
  }

  static Future showPhoneNumberActionsDialog(
    String? value, {
    String? key,
    required BuildContext context,
    DialogType type = DialogType.success,
  }) {
    String? phone = value?.removeAllWhitespace;
    if (phone == null) {
      return Future.microtask(
        () => null,
      );
    }
    launchInWhats(String phone) {
      String? encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map((MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      launchUrlString(
        """https://wa.me/964$phone?${encodeQueryParameters({'text': ''})}""",
        mode: LaunchMode.externalApplication,
      );
    }

    return Alert(
        buttons: [],
        context: context,
        type: AlertType.none,
        closeIcon: Icon(
          Icons.close,
          color: AppColor.danger,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () async {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: phone,
                );
                await launchUrl(launchUri);
                Navigator.pop(context);
              },
              child: Icon(
                Icons.phone,
                color: AppColor.white,
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                launchInWhats(phone);
              },
              backgroundColor: Colors.green,
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: AppColor.white,
              ),
            ),
            FloatingActionButton(
              backgroundColor: AppColor.primary,
              onPressed: () async {
                copy(phone, context, key: key);
                Navigator.pop(context);
              },
              child: Icon(
                Icons.copy,
                color: AppColor.white,
              ),
            ),
          ],
        )).show();
  }

  static Future<bool?> showSelectableDialog(
    String msg,
    String cancel,
    String ok, {
    BuildContext? context,
    bool invertColors = false,
    AlertType type = AlertType.none,
  }) {
    return Alert(
      type: type,
      context: context ?? Get.context!,
      title: msg,
      style: AlertStyle(titleStyle: AppFont.font12Regular),
      buttons: [
        DialogButton(
          color: invertColors ? Colors.green : Colors.red,
          child: FittedBox(
            child: Text(
              cancel,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          onPressed: () => Get.back(result: false),
        ),
        DialogButton(
          color: invertColors ? Colors.red : Colors.green,
          child: FittedBox(
            child: Text(
              ok,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          onPressed: () => Get.back(result: true),
        ),
      ],
    ).show();
  }

  static Future<bool?> showSelectableManyDialog(
    String msg, {
    BuildContext? context,
    String? desc,
    Widget? icon,
    Widget? content,
    Function? closeFunction,
  }) {
    return Alert(
      buttons: [],
      padding: EdgeInsets.zero,
      context: context ?? Get.context!,
      title: msg,
      closeIcon: const SizedBox(),
      style: AlertStyle(titleStyle: AppFont.font20W700Primary),
      image: icon,
      desc: desc,
      closeFunction: closeFunction,
      content: content == null
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.only(
                left: 0.04.sw,
                right: 0.04.sw,
                top: 0.03.sh,
              ),
              child: content,
            ),
    ).show();
  }

  static SnackbarController showGlobalSnackBar({
    String? title,
    String? text,
    Color color = Colors.grey,
    void Function(GetSnackBar)? onTap,
  }) {
    return Get.showSnackbar(
      GetSnackBar(
        messageText: text != null
            ? Text(
                text,
                style: AppFont.font14W500White,
              )
            : null,
        titleText: title != null
            ? Text(
                title,
                style: AppFont.font16W600NearlyWhite,
              )
            : null,
        snackPosition: SnackPosition.TOP,
        borderRadius: 15,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        duration: const Duration(seconds: 3),
        barBlur: 7.0,
        backgroundColor: color.withOpacity(0.7),
        dismissDirection: DismissDirection.vertical,
        onTap: onTap,
      ),
    );
  }

  static Size getTextSize(BuildContext context, String text, TextStyle style,
      {int? maxLines = 1, TextDirection? textDirection = TextDirection.ltr}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      maxLines: maxLines,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: textDirection,
    )..layout();
    return textPainter.size;
  }

  static showDateTimePickerHelper(
    BuildContext context, {
    String? date,
    required ValueChanged<String> onSelectedDateTime,
  }) {
    showDatePicker(
      locale: const Locale('ar'),
      textDirection: TextDirection.rtl,
      currentDate: DateTime.now(),
      initialDate: date == null
          ? DateTime.now()
          : intl.DateFormat('y-MM-dd', 'en').parse(date),
      firstDate: DateTime.now().subtract(const Duration(
        days: 365 * 100,
      )),
      lastDate: DateTime.now(),
      context: context,
    ).then((value) {
      if (value != null) {
        onSelectedDateTime(intl.DateFormat('y-MM-dd', 'en').format(value));
      }
    });
  }

  static void showLoadingDialog() {
    Get.dialog(
      const Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: const PageLoadingWidget(),
      ),
      barrierDismissible: false,
    );
  }
}

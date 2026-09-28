import 'package:get/get.dart';
// import 'package:translator/translator.dart';
// import 'package:heraj/core/service/local_data_manager.dart';
// import 'package:flutter/material.dart';

abstract class AppString {
  static const String appName = "KANJO";
  static String get countryCode => "+20";

  static String get currency => " ${"TRY".tr}";

  static String get shortCurrency => " ${"TL".tr}";
  static const googleMapsApiKey = "AIzaSyDSgHRg2GratUH0lb3AmjviOLiG0sebS80";
}

/// this code is commented out because it is not used in the project
/// this for translating text using google translator
//
// extension TranslateText on Text {
//   Widget translate([String? placeholder]) {
//     String? data = this.data;
//     return FutureBuilder<Translation>(
//       future: GoogleTranslator().translate(
//         data ?? '',
//         from: 'en',
//         to: dataManager.getLanguage!.locale.languageCode,
//       ),
//       builder: (BuildContext context, AsyncSnapshot<Translation> snapshot) {
//         String response = placeholder ?? "...";
//         if (snapshot.hasData) {
//           response = snapshot.data!.text;
//         }
//         return Text(
//           response,
//           key: key,
//           locale: locale,
//           maxLines: maxLines,
//           overflow: overflow,
//           semanticsLabel: semanticsLabel,
//           softWrap: softWrap,
//           strutStyle: strutStyle,
//           style: style,
//           textAlign: textAlign,
//           textDirection: textDirection,
//           textHeightBehavior: textHeightBehavior,
//           textWidthBasis: textWidthBasis,
//         );
//       },
//     );
//   }
// }

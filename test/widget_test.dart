import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_translation.dart';

void main() {
  testWidgets('translations resolve under GetMaterialApp', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: Translation(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: Scaffold(
          body: Text('View cart'.tr),
        ),
      ),
    );

    expect(find.text('View cart'), findsOneWidget);
  });
}

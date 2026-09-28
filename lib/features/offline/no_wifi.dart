import 'package:heraj/features/offline/widgets/reload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../config/app_font.dart';
import '../../../helper/responsive.dart';
import '../splash/presentation/managers/splash_provider.dart';

class NoWifi extends ConsumerWidget {
  final String? errorMessage;

  const NoWifi({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, ref) {
    responsiveInit(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/base/no_wifi.json",
                height: 0.5.sh,
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                errorMessage ?? "no internet".tr,
                style: AppFont.font20W600Black,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10.h,
              ),
              ReloadButton(
                size: 30,
                onTap: errorMessage != null
                    ? () {}
                    : () {
                        if (ref.read(hasInternetProvider).hasValue &&
                            ref.read(hasInternetProvider).value == false) {
                          ref.invalidate(hasInternetProvider);
                        }
                        ref.invalidate(hasInternetProvider2);
                      },
              )
            ],
          ),
        ),
      ),
    );
  }
}


class ViolationScreen extends ConsumerWidget {
  const ViolationScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    responsiveInit(context);
    return Scaffold(
      backgroundColor: AppColor.primary.withOpacity(.5),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/base/not-found.json",
                height: 0.5.sh,
                width: 0.8.sw,
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                "please check your Device security and try again".tr,
                style: AppFont.font20W600Black,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10.h,
              ),
              ReloadButton(
                size: 30,
                color: Colors.white,
                icon: FontAwesomeIcons.xmark,
                onTap: () => SystemNavigator.pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

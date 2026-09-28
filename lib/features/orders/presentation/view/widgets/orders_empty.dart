import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:lottie/lottie.dart';

class OrdersEmpty extends StatelessWidget {
  const OrdersEmpty({
    super.key,
    this.title,
    this.message,
  });

  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppAssets.notFound,
            height: 180,
            repeat: true,
          ),
          const Gap(16),
          Text(
            title ?? 'No orders yet'.tr,
            style: AppFont.font16W700Black,
            textAlign: TextAlign.center,
          ),
          const Gap(6),
          Text(
            message ?? 'Your orders will appear here'.tr,
            style: AppFont.font12w500Grey2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

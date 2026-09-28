import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/root/view/root_view.dart';

import '../../../../config/app_font.dart';
import '../../../../ui/shared_widgets/grediant_box.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool _goHomeClicked = false;
  bool _hasNavigated = false;

  void _goHome() {
    if (_hasNavigated) return;
    _goHomeClicked = true;
    _hasNavigated = true;
    Get.offAll(() => const RootView());
  }

  void _openOrderDetails() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    if (widget.orderId.isEmpty) {
      Get.offAll(() => const RootView());
      return;
    }
    Get.offAll(() => const RootView());
    Get.toNamed(
      '/order-details',
      parameters: {'id': widget.orderId},
    );
  }

  void _onPopInvoked(bool didPop) {
    if (didPop || _goHomeClicked || _hasNavigated) return;
    _openOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPopInvoked(didPop),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundGrey,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColor.defaultPrimaryGradient2,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColor.onAccentSurface,
                    size: 40,
                  ),
                ),
                const Gap(16),
                Text(
                  'Payment success title'.tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font20W700Black.copyWith(
                    color: AppColor.textDark,
                  ),
                ),
                const Gap(8),
                Text(
                  'Payment success message'.tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font16W400Black.copyWith(
                    color: AppColor.textBodyTertiary,
                    height: 1.5,
                  ),
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: _OutlinedGradientButton(
                        label: 'Back to home'.tr,
                        onTap: _goHome,
                      ),
                    ),
                    if (widget.orderId.isNotEmpty) ...[
                      const Gap(8),
                      Expanded(
                        child: _FilledGradientButton(
                          label: 'Order success track order'.tr,
                          onTap: _openOrderDetails,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedGradientButton extends StatelessWidget {
  const _OutlinedGradientButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(30),
            border: GradientBoxBorder(
              gradient: AppColor.defaultPrimaryGradient2,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppFont.font18W700Black.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledGradientButton extends StatelessWidget {
  const _FilledGradientButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColor.defaultPrimaryGradient2,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppFont.font18W700Black.copyWith(
                color: AppColor.onAccentSurface,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

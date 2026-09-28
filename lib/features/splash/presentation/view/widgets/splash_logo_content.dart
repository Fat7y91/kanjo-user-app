import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/logo_widget.dart';

class SplashLogoContent extends StatelessWidget {
  const SplashLogoContent({
    super.key,
    required this.logoProgress,
    required this.logoRotation,
    required this.textOpacity,
  });

  final Animation<double> logoProgress;
  final Animation<double> logoRotation;
  final Animation<double> textOpacity;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: logoProgress,
            builder: (context, child) {
              final t = 1.0 - logoProgress.value;
              return Transform.translate(
                offset: Offset(
                  -screenSize.width / 2 * t,
                  -screenSize.height / 2 * t,
                ),
                child: Transform.rotate(
                  angle: logoRotation.value,
                  child: child,
                ),
              );
            },
            child: const LogoWidget(),
          ),
          const Gap(16),
          FadeTransition(
            opacity: textOpacity,
            child: Text(
              'Q-Commerce & Delivery Platform'.tr,
              style: AppFont.font16W600Black,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

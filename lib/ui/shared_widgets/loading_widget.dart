import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_color.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Compact spinner for buttons and inline actions.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.color = AppColor.primary,
    this.size = 30,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.dotsTriangle(
        color: color,
        size: size,
      ),
    );
  }
}

/// Full-page / GET-request loading (Kanjo GIF).
class PageLoadingWidget extends StatelessWidget {
  const PageLoadingWidget({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final displaySide = context.responsiveValue(
      mobile: size,
      tablet: size * 1.5,
      desktop: size * 2,
    );

    return Center(
      child: SizedBox(
        width: displaySide,
        height: displaySide,
        child: Image.asset(
          AppAssets.kanjoLoading,
          width: displaySide,
          height: displaySide,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Image.asset(
            AppAssets.kanjoDelivery,
            width: displaySide,
            height: displaySide,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

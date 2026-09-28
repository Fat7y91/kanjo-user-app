import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

const _block = Color(0xFFECECEC);

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      enable: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 6, 16, 0).copyWith(
          bottom: MediaQuery.paddingOf(context).bottom + 80,
        ),
        children: const [
          _HeroShimmer(),
          Gap(8),
          _GalleryShimmer(),
          Gap(16),
          _TitleRowShimmer(),
          Gap(6),
          _Block(height: 14),
          Gap(6),
          _Block(height: 14, width: 220),
          Gap(14),
          _Block(height: 18, width: 90),
          Gap(10),
          _VariantsShimmer(),
          Gap(14),
          _PriceRowShimmer(),
          Gap(16),
          _Block(height: 18, width: 100),
          Gap(10),
          _AddonShimmer(),
          Gap(10),
          _AddonShimmer(),
        ],
      ),
    );
  }
}

class ProductDetailsBottomBarShimmer extends StatelessWidget {
  const ProductDetailsBottomBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      enable: true,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: const [
                Expanded(
                  child: _Block(height: 52, radius: 18),
                ),
                Gap(12),
                Expanded(
                  child: _Block(height: 52, radius: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            start: 0,
            height: 150,
            child: SvgPicture.asset(
              AppAssets.productBack,
              fit: BoxFit.fill,
            ),
          ),
          const Center(
            child: _Block(width: 190, height: 190, radius: 999),
          ),
        ],
      ),
    );
  }
}

class _GalleryShimmer extends StatelessWidget {
  const _GalleryShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: const [
          _Block(width: 72, height: 72, radius: 16),
          Gap(10),
          _Block(width: 72, height: 72, radius: 16),
          Gap(10),
          _Block(width: 72, height: 72, radius: 16),
          Gap(10),
          _Block(width: 72, height: 72, radius: 16),
        ],
      ),
    );
  }
}

class _TitleRowShimmer extends StatelessWidget {
  const _TitleRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _Block(height: 24, radius: 8)),
        Gap(6),
        _Block(width: 32, height: 32, radius: 999),
      ],
    );
  }
}

class _VariantsShimmer extends StatelessWidget {
  const _VariantsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: const [
          _VariantTileShimmer(),
          Gap(8),
          _VariantTileShimmer(),
          Gap(8),
          _VariantTileShimmer(),
        ],
      ),
    );
  }
}

class _VariantTileShimmer extends StatelessWidget {
  const _VariantTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(height: 16, width: 70, radius: 6),
          Gap(8),
          _Block(height: 12, width: 50, radius: 6),
        ],
      ),
    );
  }
}

class _PriceRowShimmer extends StatelessWidget {
  const _PriceRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Block(height: 22, width: 90, radius: 8),
        Spacer(),
        _Block(width: 108, height: 36, radius: 16),
      ],
    );
  }
}

class _AddonShimmer extends StatelessWidget {
  const _AddonShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: const Row(
        children: [
          _Block(width: 46, height: 46, radius: 999),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(height: 14, width: 120, radius: 6),
                Gap(8),
                _Block(height: 14, width: 64, radius: 6),
              ],
            ),
          ),
          Gap(12),
          _Block(width: 88, height: 38, radius: 14),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _block,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

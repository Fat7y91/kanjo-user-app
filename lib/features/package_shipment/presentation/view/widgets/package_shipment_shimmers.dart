import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

const Color _kBone = Color(0xFFE8E8E8);

class _Bone extends StatelessWidget {
  const _Bone({
    this.width,
    this.height = 12,
    this.radius = 6,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: _kBone,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _shimmerData({required Widget child}) {
  return ShimmerEffect(enable: true, child: child);
}

BoxDecoration get _cardDecoration => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.checkoutBorder),
    );

/// List screen: real cards; only title/status/address/lines shimmer.
class PackageShipmentsListShimmer extends StatelessWidget {
  const PackageShipmentsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (_, __) => const _ShipmentCardShell(),
    );
  }
}

class _ShipmentCardShell extends StatelessWidget {
  const _ShipmentCardShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerData(
                  child: const _Bone(width: double.infinity, height: 18, radius: 8),
                ),
              ),
              const Gap(12),
              _shimmerData(
                child: const _Bone(width: 72, height: 24, radius: 20),
              ),
            ],
          ),
          const Gap(12),
          _shimmerData(
            child: const _Bone(width: double.infinity, height: 12),
          ),
          const Gap(8),
          _shimmerData(
            child: const _Bone(width: 180, height: 12),
          ),
          const Gap(12),
          _shimmerData(
            child: const _Bone(width: 150, height: 14, radius: 7),
          ),
          const Gap(12),
          _shimmerData(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: double.infinity, height: 12),
                Gap(8),
                _Bone(width: 220, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Details screen: same section cards + real titles; values shimmer.
class PackageShipmentDetailsShimmer extends StatelessWidget {
  const PackageShipmentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _shimmerData(
                      child: const _Bone(
                        width: double.infinity,
                        height: 18,
                        radius: 8,
                      ),
                    ),
                  ),
                  const Gap(12),
                  _shimmerData(
                    child: const _Bone(width: 70, height: 24, radius: 20),
                  ),
                ],
              ),
              const Gap(12),
              _shimmerData(
                child: const _Bone(width: 110, height: 20, radius: 8),
              ),
              const Gap(8),
              _shimmerData(
                child: const _Bone(width: 140, height: 12),
              ),
            ],
          ),
        ),
        const Gap(12),
        _LabeledSectionShell(
          title: 'Pickup address'.tr,
          child: _shimmerData(
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(height: 20, circle: true),
                Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: double.infinity, height: 14),
                      Gap(8),
                      _Bone(width: 160, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        _LabeledSectionShell(
          title: 'Dropoffs'.tr,
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const Gap(10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.pageBackgroundGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.checkoutBorder),
                  ),
                  child: _shimmerData(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kBone,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const Gap(10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bone(width: 120, height: 14),
                              Gap(6),
                              _Bone(width: 100, height: 12),
                              Gap(6),
                              _Bone(width: double.infinity, height: 12),
                              Gap(6),
                              _Bone(width: 64, height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(12),
        _LabeledSectionShell(
          title: 'Price summary'.tr,
          child: _shimmerData(
            child: const Column(
              children: [
                _PriceLineBones(),
                Gap(8),
                _PriceLineBones(short: true),
                Gap(8),
                _PriceLineBones(short: true),
                Gap(12),
                Divider(height: 1, color: Color(0xFFE6E6E6)),
                Gap(12),
                _PriceLineBones(),
              ],
            ),
          ),
        ),
        const Gap(12),
        _LabeledSectionShell(
          title: 'Payment method'.tr,
          child: _shimmerData(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 140, height: 14),
                Gap(8),
                _Bone(width: 160, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceLineBones extends StatelessWidget {
  const _PriceLineBones({this.short = false});

  final bool short;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Bone(width: short ? 90 : 120, height: 14),
        ),
        const _Bone(width: 70, height: 14),
      ],
    );
  }
}

class _LabeledSectionShell extends StatelessWidget {
  const _LabeledSectionShell({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppFont.font16W700Black),
          const Gap(12),
          child,
        ],
      ),
    );
  }
}

/// Size step: real option cards; icon/text/radio bones shimmer.
class PackageSizeStepShimmer extends StatelessWidget {
  const PackageSizeStepShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (_, __) => const _SizeCardShell(),
    );
  }
}

class _SizeCardShell extends StatelessWidget {
  const _SizeCardShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          _shimmerData(
            child: const _Bone(width: 48, height: 48, radius: 12),
          ),
          const Gap(12),
          Expanded(
            child: _shimmerData(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 100, height: 16, radius: 7),
                  Gap(8),
                  _Bone(width: 140, height: 12),
                  Gap(6),
                  _Bone(width: 90, height: 12),
                ],
              ),
            ),
          ),
          _shimmerData(
            child: const _Bone(height: 22, circle: true),
          ),
        ],
      ),
    );
  }
}

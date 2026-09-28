import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      enable: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (_, __) => const _OrderCardPlaceholder(),
      ),
    );
  }
}

class _OrderCardPlaceholder extends StatelessWidget {
  const _OrderCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(height: 16, width: 140, radius: 6),
                    Gap(8),
                    _Block(height: 14, width: 110, radius: 6),
                  ],
                ),
                Column(
                  children: [
                    _Block(height: 24, width: 72, radius: 30),
                    Gap(8),
                    _Block(height: 14, width: 80, radius: 6),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Block(height: 40, width: 110, radius: 30),
                _Block(height: 16, width: 64, radius: 6),
              ],
            ),
          ),
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFECECEC),
              borderRadius: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(12),
                bottomEnd: Radius.circular(12),
              ),
            ),
          ),
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
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

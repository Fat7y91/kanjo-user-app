import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      enable: true,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Block(height: 168, radius: 24),
                  Gap(22),
                  _Block(height: 18, width: 130, radius: 8),
                  Gap(14),
                  _RowShimmer(),
                  Gap(10),
                  _RowShimmer(),
                  Gap(10),
                  _RowShimmer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowShimmer extends StatelessWidget {
  const _RowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          _Block(width: 44, height: 44, radius: 14),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(height: 14, width: 140, radius: 6),
                Gap(8),
                _Block(height: 12, width: 90, radius: 6),
              ],
            ),
          ),
          Gap(10),
          _Block(height: 14, width: 64, radius: 6),
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

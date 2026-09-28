import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class GamesHubShimmer extends StatelessWidget {
  const GamesHubShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
      child: ShimmerEffect(
        enable: true,
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const Gap(8),
                  Expanded(
                    child: Container(
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Gap(16),
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const Gap(12),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

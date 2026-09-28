import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj/features/home/presentation/managers/fetch_ads_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

class HomeSliders extends StatelessWidget {
  const HomeSliders({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final provider = ref.watch(fetchAdsProvider);
        return provider.customWhen(
          ref: ref,
          refreshable: fetchAdsProvider.future,
          data: (ads) {
            if (ads.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(10),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: ads.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 120,
                          child: ad.image.startsWith('assets/')
                              ? Image.asset(ad.image, fit: BoxFit.fill)
                              : Image.network(ad.image, fit: BoxFit.fill),
                        ),
                      );
                    },
                  ),
                ),
                const Gap(10),
              ],
            );
          },
          loading: () => SizedBox(
            height: 95,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => ShimmerEffect(
                enable: true,
                child: Container(
                  width: 115,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}

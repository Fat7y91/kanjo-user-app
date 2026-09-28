import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/offers/presentation/managers/offers_actions_mixin.dart';
import 'package:heraj/features/offers/presentation/managers/offers_provider.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_item_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_slider.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

final _homeOffersIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class HomeOffersComponent extends ConsumerStatefulWidget {
  const HomeOffersComponent({super.key});

  @override
  ConsumerState<HomeOffersComponent> createState() =>
      _HomeOffersComponentState();
}

class _HomeOffersComponentState extends ConsumerState<HomeOffersComponent>
    with OffersActionsMixin {
  static const double _sliderHeight = 150;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fetchOffersProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return state.customWhen(
      ref: ref,
      refreshable: fetchOffersProvider.future,
      loading: () => const _HomeOffersShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (offers) {
        if (offers.isEmpty) return const SizedBox.shrink();
        final currentIndex = ref.watch(_homeOffersIndexProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Offers'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: openAllOffers,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View all'.tr,
                            style: AppFont.font12w500Grey2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const Gap(4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomSlider(
                [
                  for (var i = 0; i < offers.length; i++)
                    OfferItemCard(
                      offer: offers[i],
                      languageCode: languageCode,
                      width: double.infinity,
                      height: _sliderHeight,
                      backgroundAsset: AppAssets.offerBacks.first,
                      onTap: () => onOfferTap(offers[i]),
                    ),
                ],
                height: _sliderHeight,
                autoPlay: offers.length > 1,
                onPageChanged: (index, _) {
                  ref.read(_homeOffersIndexProvider.notifier).state = index;
                },
              ),
            ),
            if (offers.length > 1) ...[
              CarouselIndicator(
                width: 8,
                count: offers.length,
                index: currentIndex,
                color: Colors.white.withAlpha(90),
                activeColor: Colors.white,
              ),
            ],
            const Gap(8),
          ],
        );
      },
    );
  }
}

class _HomeOffersShimmer extends StatelessWidget {
  const _HomeOffersShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Gap(24),
              ShimmerEffect(
                enable: true,
                child: Container(
                  width: 64,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerEffect(
            enable: true,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const Gap(10),
      ],
    );
  }
}

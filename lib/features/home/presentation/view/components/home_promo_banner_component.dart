import 'package:flutter/material.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/features/home/data/models/slider_model.dart';
import 'package:heraj/features/home/presentation/managers/fetch_sliders_provider.dart';
import 'package:heraj/features/home/presentation/managers/home_promo_banner_actions_mixin.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_slider.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

final _homePromoIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class HomePromoBannerComponent extends ConsumerStatefulWidget {
  const HomePromoBannerComponent({super.key});

  @override
  ConsumerState<HomePromoBannerComponent> createState() =>
      _HomePromoBannerComponentState();
}

class _HomePromoBannerComponentState extends ConsumerState<HomePromoBannerComponent>
    with HomePromoBannerActionsMixin {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fetchSlidersProvider);
    return state.customWhen(
      ref: ref,
      refreshable: fetchSlidersProvider.future,
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: ShimmerEffect(
          enable: true,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: ColoredBox(color: Colors.white),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (sliders) {
        if (sliders.isEmpty) return const SizedBox.shrink();
        final currentIndex = ref.watch(_homePromoIndexProvider);

        return Column(
          children: [
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSlider(
                sliders
                    .map(
                      (slider) => _SliderSlide(
                        slider: slider,
                        onTap: slider.canNavigate
                            ? () => onSliderTap(slider)
                            : null,
                      ),
                    )
                    .toList(),
                height: 150,
                autoPlay: sliders.length > 1,
                onPageChanged: (index, _) {
                  ref.read(_homePromoIndexProvider.notifier).state = index;
                },
              ),
            ),
            const Gap(10),
            CarouselIndicator(
              width: 8,
              count: sliders.length,
              index: currentIndex,
              color: AppColor.grey1,
              activeColor: AppColor.primary,
            ),
          ],
        );
      },
    );
  }
}

class _SliderSlide extends StatelessWidget {
  const _SliderSlide({
    required this.slider,
    this.onTap,
  });

  final SliderModel slider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ImageOrSvg(
              slider.imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          if (onTap != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          if (onTap != null)
            PositionedDirectional(
              end: 12,
              bottom: 12,
              child: IgnorePointer(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

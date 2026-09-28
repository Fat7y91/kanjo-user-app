import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';

class EmptyFavoritesState extends StatefulWidget {
  const EmptyFavoritesState({super.key});

  @override
  State<EmptyFavoritesState> createState() => _EmptyFavoritesStateState();
}

class _EmptyFavoritesStateState extends State<EmptyFavoritesState>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final AnimationController _pulseController;
  late final Animation<double> _heartAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _heartAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 96 + (_pulseAnimation.value * 32),
                    height: 96 + (_pulseAnimation.value * 32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.danger.withAlpha(
                        ((26) * (1 - _pulseAnimation.value)).round(),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80 + (_pulseAnimation.value * 24),
                    height: 80 + (_pulseAnimation.value * 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.danger.withAlpha(
                        ((38) * (1 - _pulseAnimation.value)).round(),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.danger.withAlpha(50),
                        AppColor.danger.withAlpha(25),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 48,
                    color: AppColor.danger,
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'No Products have been favorited yet.'.tr,
              style: AppFont.font16W700Black,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(8),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'go back and add some products to your favorites.'.tr,
                style: AppFont.font12w400Black.copyWith(
                  color: AppColor.grey2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Gap(24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primary2,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const Gap(8),
                        Text(
                          'Go to Products'.tr,
                          style: AppFont.font14W600Black.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

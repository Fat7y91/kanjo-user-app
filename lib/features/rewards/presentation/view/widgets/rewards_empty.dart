import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';

class RewardsEmpty extends StatefulWidget {
  const RewardsEmpty({super.key});

  @override
  State<RewardsEmpty> createState() => _RewardsEmptyState();
}

class _RewardsEmptyState extends State<RewardsEmpty>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _pulseController;
  late final Animation<double> _iconAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _iconAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
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
    _iconController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
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
                    width: 120 + (_pulseAnimation.value * 40),
                    height: 120 + (_pulseAnimation.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary.withAlpha(
                        (26 * (1 - _pulseAnimation.value)).round(),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100 + (_pulseAnimation.value * 30),
                    height: 100 + (_pulseAnimation.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary.withAlpha(
                        (38 * (1 - _pulseAnimation.value)).round(),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primary.withAlpha(50),
                            AppColor.primary.withAlpha(25),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.confirmation_number_rounded,
                        size: 64,
                        color: AppColor.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(32),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'No rewards yet'.tr,
              style: AppFont.font20W700Black,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(12),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your rewards will appear here'.tr,
                style: AppFont.font14W500Black.copyWith(
                  color: AppColor.grey2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

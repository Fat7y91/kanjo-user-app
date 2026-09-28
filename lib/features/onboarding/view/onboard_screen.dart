import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/ui/shared_widgets/glass_button.dart';
import '../../../../helper/responsive.dart';
import '../../../config/app_font.dart';
import '../../../core/service/local_data_manager.dart';
import '../../auth/presentation/view/login_page.dart';
import '../controller/onboarding_controller.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    final provider = ref.read(onboardListProvider);
    if (_currentPage < provider.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    // Get.offAll(() => const GetStartedScreen());
    dataManager.setSecondTime();
    Get.offAll(() => LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final provider = ref.watch(onboardListProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColor.defaultPrimaryGradient),
        child: Stack(
          children: [
            Positioned(
              top: context.height * 0.2,
              right: 0,
              left: 0,
              height: context.height * 0.2,
              child: Align(
                  alignment: AlignmentGeometry.center,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                        color: AppColor.white.withAlpha(100),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ]),
                  )),
            ),
            Positioned(
                bottom: 0,
                width: context.width * 1.2,
                height: context.height * 0.45,
                child: Stack(
                  children: [
                    Image.asset(
                      AppAssets.onboardBack,
                      fit: BoxFit.fill,
                      width: context.width * 1,
                      height: context.height * 0.45,
                    ),
                  ],
                )),
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: provider.length,
              itemBuilder: (context, index) {
                final item = provider[index];
                return _OnboardingPage(
                  image: item.image,
                  title: item.title,
                  subtitle: item.subTitle,
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  'Skip'.tr,
                  style: AppFont.font14W700White,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              width: context.width,
              child: _BottomNavigation(
                currentIndex: _currentPage,
                totalPages: provider.length,
                onNext: _nextPage,
                onFinish: _goToLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: MediaQuery.paddingOf(context).top + 24,
          right: 0,
          left: 0,
          height: context.height * 0.45,
          child: Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Image.asset(
              image!,
              height: context.height * 0.42,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColor.backGround);
              },
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 3,
                ),
                Text(
                  (title ?? '').tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font24w600Black.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                Text(
                  (subtitle ?? '').tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font14W500Black.copyWith(
                    color: Colors.white.withAlpha(210),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _BottomNavigation({
    required this.currentIndex,
    required this.totalPages,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == totalPages - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassButton(
            isExpanded: false,
            width: 200,
            height: 56,
            radius: 20,
            padding: EdgeInsets.zero,
            onPressed: isLastPage ? onFinish : onNext,
            child: Text(
              isLastPage ? "Let's Get Start" : "Next".tr,
              style: AppFont.font14W700White,
            ),
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: currentIndex == index ? 18 : 8,
                width: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withAlpha(125),
                  borderRadius: BorderRadius.circular(4),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}

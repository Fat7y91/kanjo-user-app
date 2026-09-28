import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../config/app_font.dart';
import '../../../../cart/presentation/managers/fetch_cart_provider.dart';

class AnimatedFB extends ConsumerWidget {
  const AnimatedFB({
    super.key,
    required this.show,
  });
  final bool show;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 120;
    final cartCount = ref.watch(fetchCartProvider).maybeWhen(
      data: (cart) => cart.items.fold<int>(0, (sum, item) => sum + item.quantity),
      orElse: () => 0,
    );
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: show ? Offset.zero : const Offset(0, 1.4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: show ? 1 : 0,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: IgnorePointer(
            ignoring: !show,
            child: _FloatingCartButton(cartCount: cartCount),
          ),
        ),
      ),
    );
  }
}

class _FloatingCartButton extends StatelessWidget {
  const _FloatingCartButton({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withAlpha(40),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => Get.toNamed('/cart'),
        customBorder: const CircleBorder(),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColor.defaultPrimaryGradient2,
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withAlpha(60),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Badge(
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColor.guestOrange,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              label: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: AppFont.font10W600White,
              ),
              child: SvgPicture.asset(
                AppAssets.bag,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
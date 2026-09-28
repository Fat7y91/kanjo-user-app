import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';

class CartEmpty extends StatefulWidget {
  const CartEmpty({super.key});

  @override
  State<CartEmpty> createState() => _CartEmptyState();
}

class _CartEmptyState extends State<CartEmpty> with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _floatController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);
    _float = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _enterController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _enterController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _float,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _float.value),
                    child: child,
                  );
                },
                child: Image.asset(
                  AppAssets.kanjoEmptyCart,
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(8),
              Text(
                'Your cart is empty'.tr,
                style: AppFont.font16W700Black.copyWith(
                  color: AppColor.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

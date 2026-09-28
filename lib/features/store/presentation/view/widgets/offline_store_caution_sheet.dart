import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';

bool isVendorOffline(VendorModel vendor) =>
    vendor.availabilityStatus.toLowerCase().trim() == 'offline';

/// Returns `true` if the user chooses to continue into the store.
Future<bool> showOfflineStoreCautionSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(90),
    builder: (_) => const OfflineStoreCautionSheet(),
  );
  return result == true;
}

class OfflineStoreCautionSheet extends StatefulWidget {
  const OfflineStoreCautionSheet({super.key});

  @override
  State<OfflineStoreCautionSheet> createState() =>
      _OfflineStoreCautionSheetState();
}

class _OfflineStoreCautionSheetState extends State<OfflineStoreCautionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnimation = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.grey1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Gap(24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColor.guestOrange.withAlpha(36),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 44,
                    color: AppColor.guestOrange,
                  ),
                ),
                const Gap(20),
                Text(
                  'Store is offline'.tr,
                  style: AppFont.font20W700Black,
                  textAlign: TextAlign.center,
                ),
                const Gap(10),
                Text(
                  'This store is currently offline. You can still browse, but ordering may be unavailable.'
                      .tr,
                  style: AppFont.font14W500Black.copyWith(
                    color: AppColor.grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                CustomOutlinedButton(
                  text: 'Cancel'.tr,
                  onPressed: () => Navigator.of(context).pop(false),
                  textSize: 14,
                ),
                const Gap(8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Continue to the store'.tr,
                    style: AppFont.font16W700Primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

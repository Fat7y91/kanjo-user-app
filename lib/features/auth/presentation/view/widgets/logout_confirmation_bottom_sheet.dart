import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';

class LogoutConfirmationBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationBottomSheet({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogoutConfirmationBottomSheet(
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  ConsumerState<LogoutConfirmationBottomSheet> createState() =>
      _LogoutConfirmationBottomSheetState();
}

class _LogoutConfirmationBottomSheetState
    extends ConsumerState<LogoutConfirmationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation
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
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColor.grey1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        // Logout icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColor.danger.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            size: 48,
                            color: AppColor.danger,
                          ),
                        ),
                        const Gap(24),
                        // Title
                        Text(
                          "Log Out?".tr,
                          style: AppFont.font20W700Black,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(12),
                        // Description
                        Text(
                          "Are you sure you want to log out of your account?".tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.grey2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomOutlinedButton(
                                text: "Cancel".tr,
                                onPressed: () => Navigator.of(context).pop(),
                                textSize: 14,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: CustomFilledButton(
                                text: "Log Out".tr,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onConfirm();
                                },
                                textSize: 14,
                                color: AppColor.danger,
                                fontColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



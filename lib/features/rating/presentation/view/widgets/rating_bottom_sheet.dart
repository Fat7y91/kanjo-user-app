import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum RatingSheetKind { vendor, delivery }

class RatingBottomSheet extends ConsumerStatefulWidget {
  const RatingBottomSheet({
    super.key,
    required this.kind,
    required this.name,
    required this.loadingKey,
    required this.onSubmit,
  });

  final RatingSheetKind kind;
  final String name;
  final String loadingKey;
  final Future<bool> Function(int rating, String comment) onSubmit;

  @override
  ConsumerState<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<RatingBottomSheet>
    with SingleTickerProviderStateMixin {
  late final FormGroup _formGroup;
  late final ValueNotifier<int> _rating;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _formGroup = FormGroup({
      'comment': FormControl<String>(value: ''),
    });
    _rating = ValueNotifier<int>(0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
    _rating.dispose();
    _formGroup.dispose();
    super.dispose();
  }

  bool get _isVendor => widget.kind == RatingSheetKind.vendor;

  Future<void> _submit() async {
    final rating = _rating.value;
    if (rating < 1) return;
    final comment =
        (_formGroup.control('comment').value as String? ?? '').trim();
    final ok = await widget.onSubmit(rating, comment);
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider(widget.loadingKey));
    final title = _isVendor ? 'Rate vendor'.tr : 'Rate delivery'.tr;
    final subtitle = widget.name.isNotEmpty
        ? (_isVendor
            ? 'How was the vendor @name'.trParams({'name': widget.name})
            : 'How was the delivery @name'.trParams({'name': widget.name}))
        : (_isVendor ? 'How was the vendor'.tr : 'How was the delivery'.tr);

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
      child: ReactiveForm(
        formGroup: _formGroup,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColor.gold.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVendor
                          ? Icons.storefront_rounded
                          : Icons.delivery_dining_rounded,
                      size: 44,
                      color: AppColor.gold,
                    ),
                  ),
                  const Gap(20),
                  Text(
                    title,
                    style: AppFont.font20W700Black,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    subtitle,
                    style: AppFont.font14W500Black.copyWith(
                      color: AppColor.grey2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),
                  ValueListenableBuilder<int>(
                    valueListenable: _rating,
                    builder: (context, rating, _) {
                      return Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final selected = star <= rating;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () => _rating.value = star,
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedScale(
                                  scale: selected ? 1.08 : 1,
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    selected
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 36,
                                    color: AppColor.gold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  const Gap(20),
                  CustomTextField<String>(
                    formControlName: 'comment',
                    hintText: 'Write a comment'.tr,
                    maxLines: 3,
                    radius: 16,
                    inputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const Gap(20),
                  ValueListenableBuilder<int>(
                    valueListenable: _rating,
                    builder: (context, rating, _) {
                      return CustomFilledButton(
                        text: 'Submit rating'.tr,
                        isLoading: isLoading,
                        isValid: rating > 0,
                        ignorePressOnNotValid: true,
                        width: MediaQuery.sizeOf(context).width - 48,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

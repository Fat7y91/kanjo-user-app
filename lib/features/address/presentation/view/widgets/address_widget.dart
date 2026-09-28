import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../core/service/loading_provider.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_outlined_button.dart';
import '../../../../../ui/ui.dart';
import '../../../data/model/address_model.dart';
import '../../../domain/use_case/address_use_cases.dart';
import '../../managers/address_provider.dart';
import '../address_details_screen.dart';

class AddressCard extends ConsumerStatefulWidget {
  final AddressModel address;
  final bool isReadOnly;
  final int index;

  const AddressCard({
    super.key,
    required this.address,
    this.isReadOnly = false,
    this.index = 0,
  });

  @override
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
        return Transform.scale(
          scale: _isHovered ? 1.02 : _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withAlpha(20),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: widget.address.isDefault
                      ? AppColor.primary.withAlpha(50)
                      : AppColor.grey1.withAlpha(30),
                  width: widget.address.isDefault ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isReadOnly
                      ? null
                      : () async {
                          final res = await Get.to(
                            () => AddressDetailsScreen(
                              address: widget.address,
                            ),
                          );
                          if (res == true) {
                            ref.invalidate(fetchAddressesProvider);
                          }
                        },
                  onTapDown: (_) => setState(() => _isHovered = true),
                  onTapUp: (_) => setState(() => _isHovered = false),
                  onTapCancel: () => setState(() => _isHovered = false),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: AppColor.primary,
                                size: 24,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.address.label,
                                          style: AppFont.font18W700Black,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.address.isDefault) ...[
                                        const Gap(8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColor.primary,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Default'.tr,
                                            style:
                                                AppFont.font10w400White.copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Gap(8),
                                  Text(
                                    widget.address.address,
                                    style: AppFont.font14W500Black.copyWith(
                                      color: AppColor.grey2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (!widget.isReadOnly) ...[
                              const Gap(8),
                              GestureDetector(
                                onTap: () => _showDeleteDialog(context, ref),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColor.danger.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColor.danger,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteAddressBottomSheet(
        addressName: widget.address.label,
        onDelete: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed != true) return;

    final isLoading = ref.read(isLoadingProvider('deleteAddress').notifier);
    isLoading.state = true;
    try {
      final result =
          await getIt<DeleteAddressUseCase>().call(widget.address.id);
      final success = result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (ok) => ok,
      );
      if (success) {
        await UIHelper.showAlert(
          'Address deleted successfully'.tr,
          type: DialogType.success,
        );
        ref.invalidate(fetchAddressesProvider);
      }
    } finally {
      isLoading.state = false;
    }
  }
}

class _DeleteAddressBottomSheet extends StatefulWidget {
  final String addressName;
  final VoidCallback onDelete;

  const _DeleteAddressBottomSheet({
    required this.addressName,
    required this.onDelete,
  });

  @override
  State<_DeleteAddressBottomSheet> createState() =>
      _DeleteAddressBottomSheetState();
}

class _DeleteAddressBottomSheetState extends State<_DeleteAddressBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.danger.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColor.danger,
                          size: 48,
                        ),
                      ),
                      const Gap(24),
                      Text(
                        'Delete Address'.tr,
                        style: AppFont.font20W700Black,
                        textAlign: TextAlign.center,
                      ),
                      const Gap(12),
                      Text(
                        'Are you sure you want to delete this address?'.tr,
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.grey2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      Text(
                        widget.addressName,
                        style: AppFont.font14W600Black,
                      ),
                      const Gap(32),
                      Row(
                        children: [
                          Expanded(
                            child: CustomOutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              text: 'Cancel'.tr,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: CustomFilledButton(
                              onPressed: widget.onDelete,
                              text: 'Delete'.tr,
                              color: AppColor.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
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

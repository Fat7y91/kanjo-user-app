import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/address/presentation/view/address_details_screen.dart';
import 'package:heraj/features/bundle_order/data/models/bundle_order_model.dart';
import 'package:heraj/features/bundle_order/domain/entities/submit_bundle_params.dart';
import 'package:heraj/features/bundle_order/domain/use_case/submit_bundle_use_case.dart';
import 'package:heraj/features/bundle_order/presentation/managers/bundle_order_providers.dart';
import 'package:heraj/features/bundle_order/presentation/view/widgets/active_bundle_order_sheet.dart';
import 'package:heraj/features/cart/presentation/managers/checkout_providers.dart';
import 'package:heraj/features/cart/presentation/managers/fetch_cart_provider.dart';
import 'package:heraj/features/cart/presentation/view/widgets/checkout_rewards_bottom_sheet.dart';
import 'package:heraj/features/rewards/data/models/reward_model.dart';
import 'package:heraj/features/rewards/presentation/managers/rewards_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';

const double _kCardRadius = 15;
const List<double> _kTipPresets = [0, 5, 10, 15, 20];
const _submitLoadingKey = 'submitBundleCheckout';

class BundleOrderCheckoutBottomSheet extends ConsumerStatefulWidget {
  const BundleOrderCheckoutBottomSheet({
    super.key,
    required this.bundle,
    this.onSubmitted,
  });

  final BundleOrderModel bundle;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<BundleOrderCheckoutBottomSheet> createState() =>
      _BundleOrderCheckoutBottomSheetState();
}

class _BundleOrderCheckoutBottomSheetState
    extends ConsumerState<BundleOrderCheckoutBottomSheet> {
  late final TextEditingController _notesController;
  late final TextEditingController _customTipController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _customTipController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _ensureDefaultAddress();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  Future<void> _ensureDefaultAddress() async {
    final current = ref.read(checkoutSelectedAddressProvider);
    if (current != null) return;
    try {
      final addresses = await ref.read(fetchAddressesProvider.future);
      if (!mounted || addresses.isEmpty) return;
      AddressModel? selected;
      for (final address in addresses) {
        if (address.isDefault) {
          selected = address;
          break;
        }
      }
      selected ??= addresses.first;
      ref.read(checkoutSelectedAddressProvider.notifier).state = selected;
    } catch (_) {}
  }

  String _money(double amount) {
    return ActiveBundleOrderSheet.money(amount);
  }

  Future<void> _pickAddress() async {
    final selected = await showModalBottomSheet<AddressModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _BundleAddressPickerSheet(),
    );
    if (selected != null && mounted) {
      ref.read(checkoutSelectedAddressProvider.notifier).state = selected;
    }
  }

  Future<void> _openRewardsSheet(double orderAmount) async {
    ref.invalidate(fetchRewardsCenterProvider);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CheckoutRewardsBottomSheet(
          orderAmount: orderAmount,
          selectedRewardId: ref.read(checkoutSelectedRewardProvider)?.id,
          onSelected: (reward) {
            ref.read(checkoutSelectedRewardProvider.notifier).state = reward;
            Navigator.of(sheetContext).pop();
          },
          onCleared: () {
            ref.read(checkoutSelectedRewardProvider.notifier).state = null;
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  Future<bool> _confirmSoloBundleIfNeeded() async {
    if (widget.bundle.participants.length > 1) return true;

    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      btnOkColor: Get.theme.primaryColor,
      title: 'No participants'.tr,
      desc:
          'There are no participants. The order will be stored as a single order. Do you want to continue?'
              .tr,
      btnCancelText: 'Cancel'.tr,
      btnOkText: 'Continue'.tr,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        confirmed = true;
      },
    ).show();
    return confirmed;
  }

  Future<void> _submit() async {
    final shouldContinue = await _confirmSoloBundleIfNeeded();
    if (!shouldContinue || !mounted) return;

    final addressId = checkoutAddressId(ref.read(checkoutSelectedAddressProvider));
    if (addressId == null) {
      UIHelper.showGlobalSnackBar(text: 'Checkout no address'.tr);
      return;
    }

    final notes = _notesController.text.trim();
    final tip = ref.read(checkoutTipAmountProvider);
    final reward = ref.read(checkoutSelectedRewardProvider);

    ref.read(isLoadingProvider(_submitLoadingKey).notifier).state = true;
    try {
      final res = await getIt<SubmitBundleUseCase>().call(
        SubmitBundleParams(
          code: widget.bundle.code,
          addressId: addressId,
          notes: notes.isEmpty ? null : notes,
          tip: tip,
          rewardId: reward?.id,
        ),
      );
      await res.fold(
        (failure) async {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (_) async {
          ref.invalidate(fetchCartProvider);
          ref.invalidate(myBundleOrdersProvider);
          ref.read(checkoutSelectedRewardProvider.notifier).state = null;
          ref.read(checkoutTipAmountProvider.notifier).state = 0;
          ref.read(checkoutNotesProvider.notifier).state = '';
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onSubmitted?.call();
          UIHelper.showGlobalSnackBar(text: 'Bundle order confirmed'.tr);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(_submitLoadingKey).notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final selectedAddress = ref.watch(checkoutSelectedAddressProvider);
    final tip = ref.watch(checkoutTipAmountProvider);
    final selectedReward = ref.watch(checkoutSelectedRewardProvider);
    final isSubmitting = ref.watch(isLoadingProvider(_submitLoadingKey));
    final subtotal = widget.bundle.subtotal;
    final rewardDiscount =
        selectedReward?.discountAmountFor(subtotal) ?? 0.0;
    final total = (subtotal - rewardDiscount + tip).clamp(0.0, double.infinity).toDouble();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.grey1,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Checkout screen title'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _BundleAddressCard(
                  address: selectedAddress,
                  onChange: _pickAddress,
                  onAdd: () async {
                    await Get.to(() => const AddressDetailsScreen());
                    ref.invalidate(fetchAddressesProvider);
                    await _ensureDefaultAddress();
                  },
                ),
                const Gap(16),
                _BundleTipsSection(
                  selectedTip: tip,
                  customController: _customTipController,
                  onSelect: (value) {
                    ref.read(checkoutTipAmountProvider.notifier).state = value;
                    if (!_kTipPresets.contains(value)) {
                      _customTipController.text = value % 1 == 0
                          ? value.toStringAsFixed(0)
                          : value.toStringAsFixed(2);
                    }
                  },
                ),
                const Gap(16),
                _BundleNotesSection(
                  controller: _notesController,
                  onChanged: (value) =>
                      ref.read(checkoutNotesProvider.notifier).state = value,
                ),
                const Gap(16),
                _BundleRewardsSection(
                  selectedReward: selectedReward,
                  languageCode: languageCode,
                  discountText: selectedReward == null
                      ? null
                      : '- ${_money(rewardDiscount)}',
                  onSelect: () => _openRewardsSheet(subtotal),
                  onClear: () =>
                      ref.read(checkoutSelectedRewardProvider.notifier).state =
                          null,
                ),
                const Gap(16),
                _BundleSummarySection(
                  subtotal: subtotal,
                  tip: tip,
                  rewardDiscount: rewardDiscount,
                  total: total,
                  money: _money,
                  rewardName: selectedReward?.name.localized(languageCode),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withAlpha(13),
                  offset: const Offset(0, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomFilledButton(
                    text: 'Confirm bundle order'.tr,
                    gradient: AppColor.defaultPrimaryGradient2,
                    radius: 16,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ),
                const Gap(12),
                Text(
                  _money(total),
                  style: AppFont.font18W700Black.copyWith(
                    color: AppColor.guestOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleAddressCard extends StatelessWidget {
  const _BundleAddressCard({
    required this.address,
    required this.onChange,
    required this.onAdd,
  });

  final AddressModel? address;
  final VoidCallback onChange;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_rounded, color: AppColor.primary, size: 28),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address?.label.isNotEmpty == true
                      ? address!.label
                      : 'Checkout no address'.tr,
                  style: AppFont.font16W700Black.copyWith(
                    color: AppColor.textDark,
                  ),
                ),
                const Gap(6),
                Text(
                  address?.address.isNotEmpty == true
                      ? address!.address
                      : 'Checkout select address'.tr,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.textBodyTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: address == null ? onAdd : onChange,
            child: Text(
              (address == null
                      ? 'Checkout add address'
                      : 'Checkout change address')
                  .tr,
              style: AppFont.font14W700Black.copyWith(
                color: AppColor.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleTipsSection extends StatelessWidget {
  const _BundleTipsSection({
    required this.selectedTip,
    required this.customController,
    required this.onSelect,
  });

  final double selectedTip;
  final TextEditingController customController;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout tip title'.tr, style: AppFont.font16W700Black),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amount in _kTipPresets)
                _BundleTipChip(
                  label: amount == 0
                      ? 'Checkout tip none'.tr
                      : '${amount.toStringAsFixed(0)} ${'EGP'.tr}',
                  selected: selectedTip == amount &&
                      customController.text.trim().isEmpty,
                  onTap: () {
                    customController.clear();
                    onSelect(amount);
                  },
                ),
            ],
          ),
          const Gap(10),
          TextField(
            controller: customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppFont.font14W500Black,
            decoration: InputDecoration(
              hintText: 'Checkout tip custom'.tr,
              hintStyle: AppFont.font14W500Black.copyWith(
                color: AppColor.textGrey,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              if (parsed != null && parsed >= 0) {
                onSelect(parsed);
              } else if (value.trim().isEmpty) {
                onSelect(0);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BundleTipChip extends StatelessWidget {
  const _BundleTipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7EFFF) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColor.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppFont.font12w500Grey2.copyWith(
            color: selected ? AppColor.primary : AppColor.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BundleNotesSection extends StatelessWidget {
  const _BundleNotesSection({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout notes title'.tr, style: AppFont.font16W700Black),
          const Gap(10),
          TextField(
            controller: controller,
            maxLines: 3,
            style: AppFont.font14W500Black,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Checkout notes placeholder'.tr,
              hintStyle: AppFont.font14W500Black.copyWith(
                color: AppColor.textGrey,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleRewardsSection extends StatelessWidget {
  const _BundleRewardsSection({
    required this.selectedReward,
    required this.languageCode,
    required this.onSelect,
    required this.onClear,
    this.discountText,
  });

  final RewardModel? selectedReward;
  final String languageCode;
  final String? discountText;
  final VoidCallback onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selected = selectedReward;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout rewards title'.tr, style: AppFont.font16W700Black),
          if (selected != null) ...[
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selected.name.localized(languageCode),
                    style: AppFont.font14W500Black,
                  ),
                ),
                if (discountText != null)
                  Text(
                    discountText!,
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.guestOrange,
                    ),
                  ),
                IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColor.textBodySecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
          const Gap(8),
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: selected == null
                  ? 'Select a reward'.tr
                  : 'Checkout change reward'.tr,
              gradient: AppColor.defaultPrimaryGradient2,
              radius: 12,
              onPressed: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleSummarySection extends StatelessWidget {
  const _BundleSummarySection({
    required this.subtotal,
    required this.tip,
    required this.rewardDiscount,
    required this.total,
    required this.money,
    this.rewardName,
  });

  final double subtotal;
  final double tip;
  final double rewardDiscount;
  final double total;
  final String Function(double) money;
  final String? rewardName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout summary title'.tr, style: AppFont.font16W700Black),
          const Gap(12),
          _BundleSummaryRow(
            label: 'Checkout summary subtotal'.tr,
            value: money(subtotal),
          ),
          if (rewardDiscount > 0) ...[
            const Gap(8),
            _BundleSummaryRow(
              label: rewardName != null && rewardName!.isNotEmpty
                  ? '${'Checkout summary reward'.tr} ($rewardName)'
                  : 'Checkout summary reward'.tr,
              value: '- ${money(rewardDiscount)}',
            ),
          ],
          if (tip > 0) ...[
            const Gap(8),
            _BundleSummaryRow(
              label: 'Checkout summary tip'.tr,
              value: money(tip),
            ),
          ],
          const Gap(10),
          const Divider(height: 1),
          const Gap(10),
          _BundleSummaryRow(
            label: 'Checkout summary total'.tr,
            value: money(total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _BundleSummaryRow extends StatelessWidget {
  const _BundleSummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? AppFont.font16W700Black
                : AppFont.font14W500Black.copyWith(
                    color: AppColor.textBodySecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: emphasize
              ? AppFont.font16W700Black.copyWith(color: AppColor.guestOrange)
              : AppFont.font14W700Black,
        ),
      ],
    );
  }
}

class _BundleAddressPickerSheet extends ConsumerWidget {
  const _BundleAddressPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(fetchAddressesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Gap(16),
            Text('Checkout select address'.tr, style: AppFont.font18W700Black),
            const Gap(12),
            Flexible(
              child: addressesAsync.customWhen(
                ref: ref,
                refreshable: fetchAddressesProvider.future,
                loading: () => const PageLoadingWidget(),
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return Center(
                      child: Text(
                        'Checkout no address'.tr,
                        style: AppFont.font14W500Black,
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColor.checkoutBorder),
                        ),
                        title: Text(
                          address.label,
                          style: AppFont.font14W700Black,
                        ),
                        subtitle: Text(
                          address.address,
                          style: AppFont.font12w500Grey2,
                        ),
                        onTap: () => Navigator.of(context).pop(address),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

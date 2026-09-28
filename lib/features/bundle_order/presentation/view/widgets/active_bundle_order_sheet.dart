import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/bundle_order/data/models/bundle_order_model.dart';
import 'package:heraj/features/bundle_order/domain/entities/bundle_order_item_entity.dart';
import 'package:heraj/features/bundle_order/domain/entities/bundle_order_participant_entity.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/ui.dart';
import 'package:share_plus/share_plus.dart';

class ActiveBundleOrderSheet extends StatefulWidget {
  const ActiveBundleOrderSheet({
    super.key,
    required this.bundle,
    this.onConfirm,
    this.isConfirming = false,
    this.onCancel,
    this.isCancelling = false,
    this.onDeleteItem,
    this.deletingItemId,
  });

  final BundleOrderModel bundle;
  final VoidCallback? onConfirm;
  final bool isConfirming;
  final VoidCallback? onCancel;
  final bool isCancelling;
  final Future<void> Function(BundleOrderItemEntity item)? onDeleteItem;
  final ValueNotifier<int?>? deletingItemId;

  static const Duration expandDuration = Duration(milliseconds: 320);
  static const Curve expandCurve = Curves.easeInOutCubic;

  static String money(double amount) {
    final text =
        amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return '$text ${'EGP'.tr}';
  }

  @override
  State<ActiveBundleOrderSheet> createState() => _ActiveBundleOrderSheetState();
}

class _ActiveBundleOrderSheetState extends State<ActiveBundleOrderSheet>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int?> _expandedIndex;
  late final ValueNotifier<bool> _codePulse;
  late final AnimationController _enterController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _expandedIndex = ValueNotifier<int?>(null);
    _codePulse = ValueNotifier<bool>(false);
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.1, 1, curve: Curves.easeOutBack),
      ),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _expandedIndex.dispose();
    _codePulse.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    final code = widget.bundle.code.trim();
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    _codePulse.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) _codePulse.value = false;
    if (!mounted) return;
    UIHelper.showGlobalSnackBar(text: 'Bundle code copied'.tr);
  }

  Future<void> _shareCode() async {
    final code = widget.bundle.code.trim();
    if (code.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join my Kango bundle order: @code'.trParams({'code': code}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final notes = widget.bundle.notes?.trim() ?? '';
    final canConfirm = widget.bundle.isHost && widget.onConfirm != null;
    final canCancel = widget.onCancel != null;
    final actionsBusy = widget.isConfirming || widget.isCancelling;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withAlpha(20),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColor.grey1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Active bundle order'.tr,
                    style: AppFont.font18W700Black,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(6),
                  Text(
                    widget.bundle.status.tr,
                    style: AppFont.font12w500Grey2.copyWith(
                      color: AppColor.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _codePulse,
                    builder: (context, pulsed, child) {
                      return AnimatedScale(
                        scale: pulsed ? 1.03 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: child,
                      );
                    },
                    child: _BundleCodeBox(
                      code: widget.bundle.code,
                      onCopy: _copyCode,
                      onShare: _shareCode,
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const Gap(10),
                    Text(
                      notes,
                      style: AppFont.font12w500Grey2.copyWith(
                        color: AppColor.textBodySecondary,
                      ),
                    ),
                  ],
                  const Gap(16),
                  Text(
                    'Participants'.tr,
                    style: AppFont.font16W700Black,
                  ),
                  const Gap(10),
                  Flexible(
                    child: widget.bundle.participants.isEmpty
                        ? Center(
                            child: Text(
                              'No participants yet'.tr,
                              style: AppFont.font14W500Black.copyWith(
                                color: AppColor.textBodySecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.bundle.participants.length,
                            separatorBuilder: (_, __) => const Gap(8),
                            itemBuilder: (context, index) {
                              final participant =
                                  widget.bundle.participants[index];
                              return _StaggeredEnter(
                                index: index,
                                child: ValueListenableBuilder<int?>(
                                  valueListenable: _expandedIndex,
                                  builder: (context, expandedIndex, _) {
                                    return _ParticipantTile(
                                      participant: participant,
                                      languageCode: languageCode,
                                      expanded: expandedIndex == index,
                                      onDeleteItem: widget.onDeleteItem,
                                      deletingItemId: widget.deletingItemId,
                                      onTap: () {
                                        _expandedIndex.value =
                                            expandedIndex == index
                                                ? null
                                                : index;
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const Gap(12),
                  const Divider(height: 1),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cart order total'.tr,
                          style: AppFont.font16W700Black,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: widget.bundle.subtotal,
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Text(
                            ActiveBundleOrderSheet.money(value),
                            style: AppFont.font16W700Black.copyWith(
                              color: AppColor.guestOrange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (canConfirm || canCancel) ...[
                    const Gap(14),
                    if (canConfirm)
                      AnimatedScale(
                        scale: widget.isConfirming ? 0.98 : 1,
                        duration: const Duration(milliseconds: 160),
                        child: CustomFilledButton(
                          text: 'Confirm bundle order'.tr,
                          gradient: AppColor.defaultPrimaryGradient2,
                          radius: 16,
                          isLoading: widget.isConfirming,
                          onPressed:
                              actionsBusy ? null : widget.onConfirm,
                        ),
                      ),
                    if (canConfirm && canCancel) const Gap(10),
                    if (canCancel)
                      CustomOutlinedButton(
                        text: 'Cancel bundle order'.tr,
                        color: AppColor.danger,
                        textColor: AppColor.danger,
                        radius: 16,
                        isLoading: widget.isCancelling,
                        onPressed: actionsBusy ? null : widget.onCancel,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredEnter extends StatefulWidget {
  const _StaggeredEnter({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredEnter> createState() => _StaggeredEnterState();
}

class _StaggeredEnterState extends State<_StaggeredEnter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420 + (widget.index * 40)),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    Future<void>.delayed(Duration(milliseconds: 80 + (widget.index * 70)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _BundleCodeBox extends StatelessWidget {
  const _BundleCodeBox({
    required this.code,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ActiveBundleOrderSheet.expandDuration,
      curve: ActiveBundleOrderSheet.expandCurve,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.pageBackgroundGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.checkoutBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bundle code'.tr,
                  style: AppFont.font12w500Grey2.copyWith(
                    color: AppColor.textBodySecondary,
                  ),
                ),
                const Gap(4),
                Text(
                  code,
                  style: AppFont.font18W700Black.copyWith(
                    color: AppColor.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _AnimatedIconAction(
            tooltip: 'Copy'.tr,
            icon: Icons.copy_rounded,
            onTap: onCopy,
          ),
          _AnimatedIconAction(
            tooltip: 'Share'.tr,
            icon: Icons.share_rounded,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _AnimatedIconAction extends StatefulWidget {
  const _AnimatedIconAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AnimatedIconAction> createState() => _AnimatedIconActionState();
}

class _AnimatedIconActionState extends State<_AnimatedIconAction> {
  late final ValueNotifier<bool> _pressed;

  @override
  void initState() {
    super.initState();
    _pressed = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pressed,
      builder: (context, pressed, _) {
        return AnimatedScale(
          scale: pressed ? 0.86 : 1,
          duration: const Duration(milliseconds: 120),
          child: IconButton(
            onPressed: () async {
              _pressed.value = true;
              widget.onTap();
              await Future<void>.delayed(const Duration(milliseconds: 120));
              if (mounted) _pressed.value = false;
            },
            tooltip: widget.tooltip,
            icon: Icon(widget.icon, color: AppColor.primary),
          ),
        );
      },
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.languageCode,
    required this.expanded,
    required this.onTap,
    this.onDeleteItem,
    this.deletingItemId,
  });

  final BundleOrderParticipantEntity participant;
  final String languageCode;
  final bool expanded;
  final VoidCallback onTap;
  final Future<void> Function(BundleOrderItemEntity item)? onDeleteItem;
  final ValueNotifier<int?>? deletingItemId;

  @override
  Widget build(BuildContext context) {
    final name = participant.name.isNotEmpty
        ? participant.name
        : 'Bundle participant'.tr;
    final itemCount = participant.items.length;

    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: ActiveBundleOrderSheet.expandDuration,
          curve: ActiveBundleOrderSheet.expandCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: expanded ? AppColor.primary : AppColor.checkoutBorder,
              width: expanded ? 1.4 : 1,
            ),
            boxShadow: expanded
                ? [
                    BoxShadow(
                      color: AppColor.primary.withAlpha(28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AnimatedScale(
                    scale: expanded ? 1.06 : 1,
                    duration: ActiveBundleOrderSheet.expandDuration,
                    curve: Curves.easeOutBack,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColor.primary.withAlpha(26),
                      child: Text(
                        name.isNotEmpty
                            ? name.substring(0, 1).toUpperCase()
                            : '?',
                        style: AppFont.font14W700Black.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.font14W700Black,
                        ),
                        const Gap(2),
                        Text(
                          '@count items'
                              .trParams({'count': itemCount.toString()}),
                          style: AppFont.font12w500Grey2,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ActiveBundleOrderSheet.money(participant.subtotal),
                    style: AppFont.font14W700Black.copyWith(
                      color: AppColor.guestOrange,
                    ),
                  ),
                  const Gap(4),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: ActiveBundleOrderSheet.expandDuration,
                    curve: ActiveBundleOrderSheet.expandCurve,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: expanded
                          ? AppColor.primary
                          : AppColor.textBodySecondary,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: ActiveBundleOrderSheet.expandDuration,
                curve: ActiveBundleOrderSheet.expandCurve,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(10),
                          const Divider(height: 1),
                          const Gap(10),
                          if (participant.items.isEmpty)
                            Text(
                              'No items'.tr,
                              style: AppFont.font12w500Grey2,
                            )
                          else
                            for (var i = 0;
                                i < participant.items.length;
                                i++) ...[
                              if (i > 0) const Gap(8),
                              _ParticipantItemRow(
                                item: participant.items[i],
                                languageCode: languageCode,
                                delayMs: 40 * i,
                                onDelete: onDeleteItem,
                                deletingItemId: deletingItemId,
                              ),
                            ],
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantItemRow extends StatefulWidget {
  const _ParticipantItemRow({
    required this.item,
    required this.languageCode,
    this.delayMs = 0,
    this.onDelete,
    this.deletingItemId,
  });

  final BundleOrderItemEntity item;
  final String languageCode;
  final int delayMs;
  final Future<void> Function(BundleOrderItemEntity item)? onDelete;
  final ValueNotifier<int?>? deletingItemId;

  @override
  State<_ParticipantItemRow> createState() => _ParticipantItemRowState();
}

class _ParticipantItemRowState extends State<_ParticipantItemRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineTotal = widget.item.lineTotal > 0
        ? widget.item.lineTotal
        : widget.item.unitPrice * widget.item.quantity;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.pageBackgroundGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.localizedName(widget.languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font14W500Black,
                    ),
                    if (widget.item.vendorName.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        widget.item.vendorName,
                        style: AppFont.font12w500Grey2,
                      ),
                    ],
                    const Gap(2),
                    Text(
                      'x${widget.item.quantity}',
                      style: AppFont.font12w500Grey2,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                ActiveBundleOrderSheet.money(lineTotal),
                style: AppFont.font14W700Black.copyWith(
                  color: AppColor.guestOrange,
                ),
              ),
              if (widget.onDelete != null) ...[
                const Gap(4),
                ValueListenableBuilder<int?>(
                  valueListenable: widget.deletingItemId ??
                      ValueNotifier<int?>(null),
                  builder: (context, deletingId, _) {
                    final isDeleting = deletingId == widget.item.id;
                    return SizedBox(
                      width: 28,
                      height: 28,
                      child: isDeleting
                          ? const LoadingWidget(
                              size: 16,
                              color: AppColor.danger,
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: deletingId != null
                                  ? null
                                  : () => widget.onDelete!(widget.item),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColor.danger,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

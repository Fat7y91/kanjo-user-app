part of '../create_package_shipment_screen.dart';

class _LocationsStep extends StatelessWidget {
  const _LocationsStep({
    super.key,
    required this.draft,
    required this.onPickPickup,
    required this.onAddDropoff,
    required this.onEditDropoff,
    required this.onRemoveDropoff,
    required this.onPickImage,
    required this.onClearImage,
  });

  final PackageShipmentDraft draft;
  final VoidCallback onPickPickup;
  final VoidCallback onAddDropoff;
  final void Function(int index, PackageDropoffInput existing) onEditDropoff;
  final ValueChanged<int> onRemoveDropoff;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'Pickup address'.tr,
              child: InkWell(
                onTap: onPickPickup,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.checkoutBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: AppColor.primary, size: 20),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          draft.pickupAddress == null
                              ? 'Select pickup address'.tr
                              : '${draft.pickupAddress!.label}\n${draft.pickupAddress!.address}',
                          style: AppFont.font14W500Black,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'Dropoffs'.tr,
              trailing: TextButton.icon(
                onPressed: onAddDropoff,
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add dropoff'.tr),
              ),
              child: draft.dropoffs.isEmpty
                  ? Text(
                      'Add one or more delivery locations'.tr,
                      style: AppFont.font12w400Black,
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < draft.dropoffs.length; i++) ...[
                          if (i > 0) const Gap(8),
                          _DropoffTile(
                            index: i,
                            dropoff: draft.dropoffs[i],
                            onEdit: () => onEditDropoff(i, draft.dropoffs[i]),
                            onRemove: () => onRemoveDropoff(i),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'Package photo'.tr,
              child: Row(
                children: [
                  if (draft.packageImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        draft.packageImage!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_outlined),
                    ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomOutlinedButton(
                          text: 'Upload photo'.tr,
                          onPressed: onPickImage,
                        ),
                        if (draft.packageImage != null) ...[
                          const Gap(8),
                          TextButton(
                            onPressed: onClearImage,
                            child: Text('Remove photo'.tr),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropoffTile extends StatelessWidget {
  const _DropoffTile({
    required this.index,
    required this.dropoff,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final PackageDropoffInput dropoff;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColor.primary2.withAlpha(100),
          ],
        ),
        border: Border.all(color: AppColor.primary.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primary2],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: AppFont.font12W600Black.copyWith(color: Colors.white),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dropoff.receiverName, style: AppFont.font14W600Black),
                const Gap(4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 14, color: AppColor.primary),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        dropoff.receiverPhone,
                        style: AppFont.font12w400Black,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 14, color: AppColor.primary),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        dropoff.dropoffAddress.trim().isNotEmpty
                            ? dropoff.dropoffAddress
                            : '${dropoff.dropoffLat.toStringAsFixed(4)}, ${dropoff.dropoffLng.toStringAsFixed(4)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.font12w400Black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 20, color: AppColor.primary),
          ),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete_outline, size: 20, color: AppColor.danger),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/address/presentation/managers/address_details_actions_mixin.dart';
import 'package:heraj/features/address/presentation/managers/address_provider.dart';
import 'package:heraj/features/address/presentation/view/widgets/address_type_selector.dart';
import 'package:heraj/features/address/presentation/view/widgets/animated_background.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({super.key, this.address});

  final AddressModel? address;

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen>
    with AddressDetailsActionsMixin, TickerProviderStateMixin {
  late final FormGroup formGroup;
  late final AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();
  GoogleMapController? _mapController;

  @override
  FormGroup get form => formGroup;

  @override
  AddressModel? get editingAddress => widget.address;

  @override
  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    formGroup = FormGroup({
      'label': FormControl<String>(
        validators: [Validators.required],
        value: widget.address?.label.isNotEmpty == true
            ? widget.address!.label
            : 'Home',
      ),
      'address': FormControl<String>(
        validators: [Validators.required],
        value: widget.address?.address,
      ),
      'latitude': FormControl<double>(
        validators: [Validators.required],
        value: widget.address?.latitude ?? 30.0444,
      ),
      'longitude': FormControl<double>(
        validators: [Validators.required],
        value: widget.address?.longitude ?? 31.2357,
      ),
      'is_default': FormControl<bool>(
        value: widget.address?.isDefault ?? false,
      ),
    });

    formGroup.control('latitude').valueChanges.listen((_) {
      _animateMap();
    });
    formGroup.control('longitude').valueChanges.listen((_) {
      _animateMap();
    });
  }

  void _animateMap() {
    final position = mapPosition;
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  void dispose() {
    formGroup.dispose();
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AddressAnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          ReactiveForm(
            formGroup: formGroup,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColor.black,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: isEditing
                      ? [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              end: 12,
                              top: 8,
                              bottom: 8,
                            ),
                            child: SizedBox(
                              width: 100,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  return CustomFilledButton(
                                    onPressed: deleteAddress,
                                    text: 'Delete'.tr,
                                    isLoading: ref.watch(
                                      isLoadingProvider('deleteAddress'),
                                    ),
                                    textSize: 15,
                                    color: AppColor.primary.withAlpha(200),
                                    fontWeight: FontWeight.w500,
                                  );
                                },
                              ),
                            ),
                          ),
                        ]
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    centerTitle: true,
                    title: Text(
                      isEditing ? 'Edit address'.tr : 'Add address'.tr,
                      style: AppFont.font18W700Black,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReactiveValueListenableBuilder(
                          formControlName: 'latitude',
                          builder: (context, latControl, _) {
                            return ReactiveValueListenableBuilder(
                              formControlName: 'longitude',
                              builder: (context, lngControl, _) {
                                final position = mapPosition;
                                return Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: GoogleMap(
                                        onMapCreated: (controller) {
                                          _mapController = controller;
                                        },
                                        markers: {
                                          Marker(
                                            markerId:
                                                const MarkerId('address'),
                                            position: position,
                                          ),
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: position,
                                          zoom: 15,
                                        ),
                                        myLocationEnabled: true,
                                        zoomControlsEnabled: false,
                                        scrollGesturesEnabled: false,
                                        zoomGesturesEnabled: false,
                                        tiltGesturesEnabled: false,
                                        rotateGesturesEnabled: false,
                                      ),
                                    ),
                                    const Gap(16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child:
                                              ReactiveValueListenableBuilder(
                                            formControlName: 'address',
                                            builder: (context, control, _) {
                                              final value =
                                                  control.value?.toString();
                                              return Text(
                                                '${'Area'.tr}\n${value?.isNotEmpty == true ? value : 'Select location'.tr}',
                                                maxLines: 2,
                                                style: AppFont.font14W700Black,
                                              );
                                            },
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: openLocationSelector,
                                          child: Text(
                                            isEditing
                                                ? 'Change'.tr
                                                : 'Add'.tr,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const Gap(16),
                        const Wrap(
                          spacing: 8,
                          children: [
                            AddressTypeSelectorWidget(
                              type: AddressType.apartment,
                              icon: Icons.apartment,
                            ),
                            AddressTypeSelectorWidget(
                              type: AddressType.home,
                              icon: Icons.home,
                            ),
                            AddressTypeSelectorWidget(
                              type: AddressType.work,
                              icon: Icons.business,
                            ),
                          ],
                        ),
                        const Gap(16),
                        CustomTextField(
                          formControlName: 'address',
                          hintText: 'Address'.tr,
                        ),
                        const Gap(8),
                        ReactiveFormConsumer(
                          builder: (context, form, _) {
                            final isDefault =
                                form.control('is_default').value as bool? ??
                                    false;
                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Set as default address'.tr,
                                style: AppFont.font14W600Black,
                              ),
                              value: isDefault,
                              activeThumbColor: AppColor.primary,
                              onChanged: (v) =>
                                  form.control('is_default').value = v,
                            );
                          },
                        ),
                        const Gap(24),
                        SizedBox(
                          width: double.infinity,
                          child: Consumer(
                            builder: (context, ref, _) {
                              return CustomFilledButton(
                                onPressed: saveAddress,
                                isLoading: ref.watch(
                                  isLoadingProvider('saveAddress'),
                                ),
                                isValid: formGroup.valid,
                                fontWeight: FontWeight.w400,
                                textSize: 18,
                                text: isEditing
                                    ? 'Save address'.tr
                                    : 'Add address'.tr,
                              );
                            },
                          ),
                        ),
                        Gap(MediaQuery.of(context).padding.bottom + 24),
                      ],
                    ),
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

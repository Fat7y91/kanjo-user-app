import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/ui.dart';
import '../managers/auth_provuder.dart';
import '../../../profile/domain/use_cases/upload_file_use_case.dart';

class VendorRegisterPage extends ConsumerStatefulWidget {
  const VendorRegisterPage({super.key});

  @override
  ConsumerState<VendorRegisterPage> createState() => _VendorRegisterPageState();
}

class _VendorRegisterPageState extends ConsumerState<VendorRegisterPage>
    with PhoneValidationMixin {
  late final FormGroup formGroup;
  final FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    super.initState();
    formGroup = FormGroup({
      'storeName': FormControl<String>(validators: [Validators.required]),
      'storeNameAr': FormControl<String>(validators: [Validators.required]),
      'storeNameTr': FormControl<String>(validators: [Validators.required]),
      'description': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
          validators: [Validators.required, Validators.email]),
      'country_code': FormControl<String>(
        value: '+90',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        validators: [Validators.required],
      ),
      'store_logo': FormControl<File>(),
      'business_document': FormControl<File>(),
    });

    formGroup.control('phone').setValidators([
      Validators.required,
      Validators.minLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
      Validators.maxLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
    ]);

    formGroup.control('country_code').valueChanges.listen((_) {
      formGroup.control('phone').updateValueAndValidity();
    });
  }

  @override
  void dispose() {
    super.dispose();
    formGroup.dispose();
    phoneNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    responsiveInit(context);
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppAssets.getStarted2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColor.backGround);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(70),
                        Colors.black.withAlpha(140),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: MediaQuery.of(context).padding.top + 20,
                  end: 0,
                  start: 0,
                  child: Image.asset(
                    AppAssets.logo,
                    height: 100,
                    width: 100,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -height * 0.5,
            left: -width * 0.5,
            right: -width * 0.5,
            child: CircleAvatar(
              radius: height * 0.85,
              backgroundColor: AppColor.white,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ReactiveForm(
              formGroup: formGroup,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!'.tr,
                        style: AppFont.font24w600Black.copyWith(
                          color: AppColor.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(10),
                      CustomTextField(
                        formControlName: 'storeName',
                        hintText: 'Store Name (English)'.tr,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      const Gap(10),
                      CustomTextField(
                        formControlName: 'storeNameAr',
                        hintText: 'Store Name (Arabic)'.tr,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      const Gap(10),
                      CustomTextField(
                        formControlName: 'storeNameTr',
                        hintText: 'Store Name (Turkish)'.tr,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      const Gap(10),
                      CustomTextField(
                        formControlName: 'description',
                        hintText: 'Store Description'.tr,
                        borderRadius: BorderRadius.circular(25),
                        maxLines: 3,
                      ),
                      const Gap(10),
                      CustomTextField(
                        formControlName: 'email',
                        hintText: 'Email Address'.tr,
                        inputType: TextInputType.emailAddress,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      const Gap(10),
                      Row(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReactiveValueListenableBuilder<String>(
                            formControlName: 'country_code',
                            builder: (context, countryCodeControl, child) {
                              final phoneCode =
                                  (!(countryCodeControl.value?.contains("+") ??
                                              false)
                                          ? '+${countryCodeControl.value}'
                                          : countryCodeControl.value) ??
                                      '+90';
                              Country country =
                                  getCountryFromPhoneCode(phoneCode);

                              return InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    onSelect: (Country selectedCountry) {
                                      formGroup
                                          .control('country_code')
                                          .updateValue(
                                            selectedCountry.phoneCode,
                                            emitEvent: true,
                                          );
                                    },
                                    countryListTheme: CountryListThemeData(
                                      flagSize: 24,
                                      backgroundColor: Colors.white,
                                      textStyle: AppFont.font14W500Black,
                                      inputDecoration: InputDecoration(
                                        labelText: 'Search'.tr,
                                        hintText: 'Start typing to search'.tr,
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.grey1,
                                          ),
                                        ),
                                      ),
                                      searchTextStyle: AppFont.font14W500Black,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 100,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColor.grey1,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: AppColor.grey1),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        country.flagEmoji,
                                        style: AppFont.font20W700Black,
                                      ),
                                      const Gap(6),
                                      Text(
                                        country.phoneCode,
                                        style: AppFont.font14W500Black,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: CustomTextField(
                              radius: 25,
                              formControlName: "phone",
                              hintText: "Enter Phone Number".tr,
                              inputType: TextInputType.phone,
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              focusNode: phoneNode,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return InkWell(
                            onTap: () async {
                              final imagePicker = getIt<ImagePickerService>();
                              final file = await imagePicker.pickImage();
                              if (file != null) {
                                form.control('store_logo').updateValue(file);
                              }
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColor.grey1,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: AppColor.grey1),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      form.control('store_logo').value != null
                                          ? 'Store Logo Selected'.tr
                                          : 'Upload Store Logo'.tr,
                                      style: AppFont.font14W500Black.copyWith(
                                        color:
                                            form.control('store_logo').value !=
                                                    null
                                                ? AppColor.primary
                                                : AppColor.grey2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.upload_file,
                                    color: AppColor.grey2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(10),
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return InkWell(
                            onTap: () async {
                              final imagePicker = getIt<ImagePickerService>();
                              final file = await imagePicker.pickImage();
                              if (file != null) {
                                form
                                    .control('business_document')
                                    .updateValue(file);
                              }
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColor.grey1,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: AppColor.grey1),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      form.control('business_document').value !=
                                              null
                                          ? 'Business Document Selected'.tr
                                          : 'Upload Business Document'.tr,
                                      style: AppFont.font14W500Black.copyWith(
                                        color: form
                                                    .control(
                                                        'business_document')
                                                    .value !=
                                                null
                                            ? AppColor.primary
                                            : AppColor.grey2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.upload_file,
                                    color: AppColor.grey2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(16),
                      CustomReactiveFormValidationConsumer(
                        formGroup: formGroup,
                        builder: (context, _, child) {
                          return Consumer(builder: (context, ref, child) {
                            final isLoading = ref.watch(authNotifierProvider);
                            return CustomFilledButton(
                              isLoading: isLoading,
                              isValid: formGroup.valid,
                              text: "Sign Up".tr,
                              textSize: 16,
                              color: AppColor.primary,
                              fontColor: Colors.white,
                              onPressed: () async {
                                if (formGroup.valid) {
                                  UIHelper.showLoadingDialog();

                                  try {
                                    String? storeLogoUrl;
                                    String? businessDocumentUrl;

                                    // Upload store logo if provided
                                    final storeLogo = formGroup
                                        .control('store_logo')
                                        .value as File?;
                                    if (storeLogo != null) {
                                      final uploadResult =
                                          await getIt<UploadFileUseCase>()
                                              .call(storeLogo);
                                      uploadResult.fold(
                                        (failure) => throw Exception(
                                            'Failed to upload store logo: ${failure.message}'),
                                        (uploadModel) =>
                                            storeLogoUrl = uploadModel.filePath,
                                      );
                                    }

                                    // Upload business document if provided
                                    final businessDoc = formGroup
                                        .control('business_document')
                                        .value as File?;
                                    if (businessDoc != null) {
                                      final uploadResult =
                                          await getIt<UploadFileUseCase>()
                                              .call(businessDoc);
                                      uploadResult.fold(
                                        (failure) => throw Exception(
                                            'Failed to upload business document: ${failure.message}'),
                                        (uploadModel) => businessDocumentUrl =
                                            uploadModel.filePath,
                                      );
                                    }

                                    Get.back(); // Close loading dialog

                                    // Prepare registration data
                                    final countryCode = formGroup
                                        .value['country_code'] as String;
                                    final phoneNumber =
                                        formGroup.value['phone'] as String;
                                    final map = {
                                      'storeName': formGroup.value['storeName'],
                                      'storeNameAr':
                                          formGroup.value['storeNameAr'],
                                      'storeNameTr':
                                          formGroup.value['storeNameTr'],
                                      'description':
                                          formGroup.value['description'],
                                      'email': formGroup.value['email'],
                                      'phone': '$countryCode$phoneNumber',
                                      if (storeLogoUrl != null)
                                        'store_logo': storeLogoUrl,
                                      if (businessDocumentUrl != null)
                                        'business_document':
                                            businessDocumentUrl,
                                    };

                                    await ref
                                        .read(authNotifierProvider.notifier)
                                        .vendorRegister(map);
                                  } catch (e) {
                                    Get.back(); // Close loading dialog if still open
                                    UIHelper.showAlert(e.toString(),
                                        type: DialogType.error);
                                  }
                                } else {
                                  formGroup.markAllAsTouched();
                                }
                              },
                            );
                          });
                        },
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

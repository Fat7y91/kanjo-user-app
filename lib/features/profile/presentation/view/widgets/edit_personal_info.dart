import 'package:country_picker/country_picker.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:heraj/helper/phone_validation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../../config/app_color.dart';
import '../../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../../ui/shared_widgets/gender_selector.dart';
import '../../../../../config/app_font.dart';

class EditPersonalInfo extends ConsumerWidget {
  const EditPersonalInfo({
    super.key,
    required this.formGroup,
    required this.phoneValidationMixin,
  });

  final FormGroup formGroup;
  final PhoneValidationMixin phoneValidationMixin;

  Future<void> _pickBirthdate(BuildContext context) async {
    final control = formGroup.control('birthdate') as FormControl<String>;
    final current = control.value;
    DateTime initial = DateTime(2000, 1, 1);
    if (current != null && current.isNotEmpty) {
      initial = DateTime.tryParse(current) ?? initial;
    }
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    control.updateValue(DateFormat('yyyy-MM-dd').format(picked));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(10),
        CustomTextField(
          formControlName: "name",
          labelText: "name".tr,
          borderRadius: BorderRadius.circular(12),
        ),
        const Gap(12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: CustomTextField(
                formControlName: "phone",
                hintText: "phone".tr,
                labelText: "phone".tr,
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 2,
              child: ReactiveValueListenableBuilder<String>(
                formControlName: 'countryCode',
                builder: (context, countryCodeControl, child) {
                  final phoneCode =
                      (!(countryCodeControl.value?.contains("+") ?? false)
                              ? '+${countryCodeControl.value}'
                              : countryCodeControl.value) ??
                          '+20';
                  final country =
                      phoneValidationMixin.getCountryFromPhoneCode(phoneCode);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "code".tr,
                        style: AppFont.font14W500Black,
                        textAlign: TextAlign.start,
                      ),
                      Gap(10.h),
                      InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            onSelect: (Country selectedCountry) {
                              formGroup.control('countryCode').updateValue(
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
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColor.grey1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                country.flagEmoji,
                                style: AppFont.font20W700Black,
                              ),
                              const Gap(6),
                              Flexible(
                                child: Text(
                                  country.phoneCode,
                                  style: AppFont.font14W500Black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const Gap(12),
        CustomTextField(
          formControlName: "email",
          labelText: "Email".tr,
        ),
        const Gap(12),
        CustomTextField(
          formControlName: 'birthdate',
          labelText: 'Birthday'.tr,
          hintText: 'Select birthday'.tr,
          ignore: true,
          onTap: () => _pickBirthdate(context),
          iconButton: Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: AppColor.grey2,
          ),
        ),
        const Gap(12),
        const GenderSelector(),
        const Gap(50),
      ],
    );
  }
}

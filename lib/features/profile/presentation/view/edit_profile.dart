import 'package:heraj/features/profile/presentation/view/widgets/edit_profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/features/profile/presentation/view/widgets/edit_personal_info.dart';
import 'package:heraj/models/user_model.dart';
import 'package:heraj/ui/shared_widgets/animated_background.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/map_not_equals_validator.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import 'widgets/edit_profile_confirm_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with PhoneValidationMixin, TickerProviderStateMixin {
  late final FormGroup formGroup;
  UserModel? _initialUser;
  late AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialUser = ref.read(userProvider);
    _initializeForm();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  void _initializeForm() {
    final user = _initialUser;
    final rawPhone = user?.phone ?? '';
    final countryCode =
        inferCountryCode(rawPhone, user?.countryCode) ?? '+20';
    formGroup = FormGroup({
      'name': FormControl<String>(
        validators: [Validators.required],
        value: user?.name ?? '',
      ),
      'avatar': FormControl<String>(
        validators: [],
        value: user?.image,
      ),
      'phone': FormControl<String>(
        validators: [Validators.required],
        value: localPhoneNumber(rawPhone, countryCode),
      ),
      'countryCode': FormControl<String>(
        validators: [Validators.required],
        value: countryCode,
      ),
      'email': FormControl<String>(
        value: user?.email ?? '',
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'birthdate': FormControl<String>(
        value: _normalizedBirthdate(user?.birthdate),
      ),
      'gender': FormControl<String>(
        value: user?.gender,
        validators: [Validators.required],
      ),
    });

    _setupPhoneValidation();

    formGroup.setValidators([
      MapNotEqualsValidator(Map.from(formGroup.value)),
    ], autoValidate: true);
  }

  void _setupPhoneValidation() {
    final phoneControl = formGroup.control('phone');
    final countryCodeControl = formGroup.control('countryCode');

    countryCodeControl.valueChanges.listen((_) {
      final phoneLength =
          getPhoneLengthForCountryCode(countryCodeControl.value);
      if (phoneLength != null) {
        phoneControl.setValidators([
          Validators.required,
          Validators.minLength(phoneLength),
          Validators.maxLength(phoneLength),
        ]);
      } else {
        phoneControl.setValidators([Validators.required]);
      }
      phoneControl.updateValueAndValidity();
    });

    final initialPhoneLength =
        getPhoneLengthForCountryCode(countryCodeControl.value);
    if (initialPhoneLength != null) {
      phoneControl.setValidators([
        Validators.required,
        Validators.minLength(initialPhoneLength),
        Validators.maxLength(initialPhoneLength),
      ]);
    }
  }

  String? _normalizedBirthdate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.trim();
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
    final userId = ref.watch(userProvider.select((user) => user?.id));
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Animated AppBar
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
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    "Profile".tr,
                    style: AppFont.font20W700Black,
                  ),
                  centerTitle: false,
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: ReactiveForm(
                      formGroup: formGroup,
                      child: Column(
                        children: [
                          EditProfileImageWidget(
                            ref: ref,
                            formGroup: formGroup,
                          ),
                          const Gap(10),
                          Text(
                            "ID: #${userId ?? ''}",
                            style: AppFont.subLabelTextField
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(10),
                          EditPersonalInfo(
                            formGroup: formGroup,
                            phoneValidationMixin: this,
                          ),
                          Gap(MediaQuery.of(context).padding.bottom + 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Floating Save Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 12,
                right: 12,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
              child: EditProfileConfirmButton(formGroup: formGroup),
            ),
          ),
        ],
      ),
    );
  }
}

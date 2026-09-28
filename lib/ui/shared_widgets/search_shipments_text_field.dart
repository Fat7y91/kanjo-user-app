import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../config/app_font.dart';
import '../../helper/responsive.dart';
import '../ui.dart';
import 'custom_reactive_form_consumer.dart';

class SearchShipmentsTextField extends ConsumerStatefulWidget {
  const SearchShipmentsTextField({
    super.key,
    required this.control,
    this.text,
    this.provider,
    this.focused = false,
  });

  final bool focused;
  final String? text;
  final FormControl<String?> control;
  final AutoDisposeStateProvider<String?>? provider;

  @override
  ConsumerState<SearchShipmentsTextField> createState() =>
      _SearchShipmentsTextFieldState();
}

class _SearchShipmentsTextFieldState
    extends ConsumerState<SearchShipmentsTextField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    if (widget.focused) {
      _focus.requestFocus();
    }
  }

  final hasFocusProvider = StateProvider.autoDispose<bool>((ref) {
    return false;
  });

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  _onFocusChange() {
    ref.read(hasFocusProvider.notifier).state = _focus.hasFocus;
  }

  final _debouncer = CustomDelay(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return ReactiveTextField(
        showCursor: false,
        onChanged: (value) {
          _debouncer.run(() {
            if (widget.provider != null) {
              ref.read(widget.provider!.notifier).state = value.value;
            }
          });
        },
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        focusNode: _focus,
        showErrors: (_) {
          return false;
        },
        style: AppFont.font14W500Grey2,
        textAlignVertical: TextAlignVertical.top,
        formControl: widget.control,
        maxLines: 1,
        textInputAction: TextInputAction.search,
        cursorHeight: UIHelper.getTextSize(
          context,
          '',
          AppFont.font14W500Grey2,
        ).height,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          constraints: BoxConstraints(
            maxHeight: 37.h,
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(8.w),
              CustomReactiveControlValidationConsumer(
                control: widget.control,
                builder: (context, control, child) {
                  final isValid = control.valid;
                  return Row(
                    children: [
                      InkWell(
                        onTap: isValid ? () {} : null,
                        child: SvgPicture.asset(
                          "assets/base/search.svg",
                          color: isValid ? AppColor.primary : AppColor.grey1,
                          height: 19.h,
                          width: 19.h,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Consumer(
                        child: Row(
                          children: [
                            Gap(8.w),
                            IgnorePointer(
                              ignoring: true,
                              child: Align(
                                alignment: const AlignmentDirectional(-0.6, 0),
                                child: Text(
                                  widget.text ?? "Search a Shipment".tr,
                                  style: AppFont.font14W500Grey2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        builder: (context, ref, child) {
                          if (!ref.watch(hasFocusProvider) && !isValid) {
                            return child!;
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(8.w),
              CustomReactiveControlValidationConsumer(
                control: widget.control,
                builder: (context, control, child) {
                  final isValid = control.valid;
                  if (!isValid) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    children: [
                      InkWell(
                        onTap: isValid
                            ? () {
                                widget.control.value = null;
                                if (widget.provider != null) {
                                  ref.read(widget.provider!.notifier).state =
                                      null;
                                }
                              }
                            : null,
                        child: Icon(
                          Icons.close,
                          color: isValid ? AppColor.primary : AppColor.grey1,
                          size: 19.h,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          fillColor: AppColor.nearlyWhite,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.0),
          ),
        ));
  }
}

class CustomDelay {
  int milliseconds;
  Timer? _timer;

  CustomDelay({required this.milliseconds});

  cancel() {
    _timer?.cancel();
  }

  run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

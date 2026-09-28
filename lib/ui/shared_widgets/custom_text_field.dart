import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../config/app_font.dart';
import '../../helper/responsive.dart';

enum TextFieldType { text, selectable }

class CustomTextField<T> extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.formControlName,
    this.autofillHints,
    this.radius = 25,
    this.inputType = TextInputType.text,
    this.style = 1,
    this.inputFormatter,
    this.paddingFromTop = false,
    this.onEditDone,
    this.onTap,
    this.obscure = false,
    this.maxLines = 1,
    this.control,
    this.iconDataPrefix,
    this.iconColor = Colors.grey,
    this.iconButton,
    this.type = TextFieldType.text,
    this.items,
    this.onChanged,
    this.borderRadius,
    this.hideSelectableIconIfIgnore = true,
    this.ignore = false,
    this.labelText,
    this.prefixText,
    this.suffixText,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.fillColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.borderWidth,
    this.hintStyle,
    this.textStyle,
    this.textAlign,
    this.textDirection,
  });

  final Iterable<String>? autofillHints;
  final String? formControlName;
  final FormControl<T>? control;
  final String? hintText;
  final String? labelText;
  final FocusNode? focusNode;
  final int style;
  final Widget? iconButton;
  final bool obscure;
  final bool ignore;
  final double radius;
  final int maxLines;
  final VoidCallback? onEditDone;
  final bool paddingFromTop;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType inputType;
  final void Function()? onTap;
  final TextFieldType type;
  final List<DropdownMenuItem<T>>? items;
  final String? prefixText;
  final String? suffixText;
  final Widget? iconDataPrefix;
  final Color iconColor;
  final ReactiveFormFieldCallback<T>? onChanged;
  final BorderRadius? borderRadius;
  final bool hideSelectableIconIfIgnore;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final double? borderWidth;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final validation = {
      ValidationMessage.email: (controller) => ValidationMessage.email.tr,
      ValidationMessage.required: (controller) => ValidationMessage.required.tr,
      ValidationMessage.number: (controller) => ValidationMessage.number.tr,
      ValidationMessage.minLength: (controller) =>
          ValidationMessage.minLength.tr,
      ValidationMessage.maxLength: (controller) =>
          ValidationMessage.maxLength.tr,
      ValidationMessage.mustMatch: (controller) =>
          ValidationMessage.mustMatch.tr,
    };
    final InputDecoration decoration = InputDecoration(
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: AppFont.labelTextField,
      filled: true,
      fillColor: fillColor,
      suffixIcon: iconButton,
      prefixIcon: iconDataPrefix,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      prefixStyle: AppFont.textFiled,
      suffixStyle: AppFont.textFiled,
      hintStyle: hintStyle ?? AppFont.hintTextField,
      border: OutlineInputBorder(
        borderRadius:
            borderRadius ?? BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(
          color: AppColor.primary,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius:
            borderRadius ?? BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(
          color: enabledBorderColor ?? AppColor.grey1,
          width: borderWidth ?? 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            borderRadius ?? BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(
          color: enabledBorderColor ?? AppColor.grey1,
          width: borderWidth ?? 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            borderRadius ?? BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(
          color: focusedBorderColor ?? AppColor.primary,
          width: borderWidth ?? 2,
        ),
      ),
      constraints: BoxConstraints(minHeight: 48, maxHeight: 62),
    );
    final wid = type == TextFieldType.text
        ? ReactiveTextField<T>(
            autofillHints: autofillHints,
            contextMenuBuilder: (context, editableTextState) {
              final items = editableTextState.contextMenuButtonItems;
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: items,
              );
            },
            // onTapOutside: (controller) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // },
            textInputAction: textInputAction ??
                (inputType == TextInputType.multiline
                    ? TextInputAction.newline
                    : TextInputAction.next),
            formControl: control,
            onSubmitted: (controller) {
              if (focusNode != null) {
                focusNode!.nextFocus();
              } else {
                FocusManager.instance.primaryFocus?.nextFocus();
              }
            },
            onEditingComplete: (controller) {
              if (focusNode != null) {
                focusNode!.nextFocus();
              } else {
                FocusManager.instance.primaryFocus?.nextFocus();
              }
              onEditDone?.call();
            },
            onTap: onTap == null
                ? null
                : (controller) {
                    onTap!.call();
                  },
            keyboardType: inputType,
            maxLines: maxLines,
            inputFormatters: [
              ...?inputFormatter,
              if (inputType == TextInputType.phone)
                FilteringTextInputFormatter.digitsOnly
            ],
            obscureText: obscure,
            style: textStyle ?? AppFont.textFiled,
            textAlign: textAlign ?? TextAlign.start,
            textDirection: textDirection,
            textAlignVertical: maxLines > 1
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            formControlName: formControlName,
            decoration: decoration,
            validationMessages: validation,
            onChanged: onChanged,
          )
        : ReactiveDropdownField<T>(
            iconEnabledColor: AppColor.primary,
            iconDisabledColor: AppColor.disabled,
            itemHeight: kMinInteractiveDimension,
            isDense: false,
            icon: ignore && hideSelectableIconIfIgnore
                ? const SizedBox.shrink()
                : null,
            formControl: formControlName != null ? null : control,
            onTap: onTap == null
                ? null
                : (controller) {
                    onTap!.call();
                  },
            onChanged: onChanged,
            style: AppFont.textFiled,
            formControlName: formControlName,
            decoration: decoration,
            items: items!,
            validationMessages: validation,
          );
    return Column(
      children: [
        if (labelText != null)
          Column(
            children: [
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Text(
                  labelText!,
                  style: AppFont.font14W500Black,
                  textAlign: TextAlign.start,
                ),
              ),
              Gap(10),
            ],
          ),
        InkWell(
          onTap: ignore ? onTap : null,
          child: IgnorePointer(
            ignoring: ignore,
            child: wid,
          ),
        ),
      ],
    );
  }
}

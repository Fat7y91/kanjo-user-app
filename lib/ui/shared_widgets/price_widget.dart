import 'package:flutter/material.dart';
import 'package:heraj/core/service/localization_service/localization_service.dart';
import '../../config/app_font.dart';

class PriceWidget extends StatelessWidget {
  final String price;
  final TextStyle? style;
  final Color? textColor;
  final double? currencySize;
  final bool showCurrency;
  final TextDecoration? decoration;

  const PriceWidget({
    super.key,
    required this.price,
    this.style,
    this.textColor,
    this.currencySize,
    this.showCurrency = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$price ${_getCurrencySymbol()}",
          style: (style ?? AppFont.font14W600Black).copyWith(
            color: textColor,
            decoration: decoration,
          ),
        ),
      ],
    );
  }
}

String _getCurrencySymbol() {
  switch (localeService.getLocale().locale.languageCode) {
    // case 'tr':
    //   return '₺';
    // case 'en':
    //   return '\$';
    // case 'ar':
    //   return '€';
    default:
      return '₺';
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({
    super.key,
    required this.offer,
    this.applySafeArea = true,
  });

  final OfferModel offer;
  final bool applySafeArea;

  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final name = offer.name.localized(languageCode);
    final description = offer.description.localized(languageCode);
    final message = description.isNotEmpty ? '$name\n$description' : name;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColor.guestOrange,
            size: 22,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: AppFont.font12w500Grey2.copyWith(
                color: AppColor.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      color: AppColor.white,
      child: Material(
        color: AppColor.guestOrange.withAlpha(26),
        child: applySafeArea
            ? SafeArea(top: false, child: content)
            : content,
      ),
    );
  }
}

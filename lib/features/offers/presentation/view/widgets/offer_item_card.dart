import 'package:flutter/material.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/features/offers/data/models/offer_model.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class OfferItemCard extends StatelessWidget {
  const OfferItemCard({
    super.key,
    required this.offer,
    this.languageCode,
    this.onTap,
    this.width,
    this.height = 120,
    this.backgroundAsset,
  });

  final OfferModel offer;
  final String? languageCode;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final String? backgroundAsset;

  @override
  Widget build(BuildContext context) {
    final networkImage = offer.imageUrl?.trim();
    final hasNetworkImage = networkImage != null && networkImage.isNotEmpty;
    final fallbackAsset = backgroundAsset ?? AppAssets.offerBacks.first;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasNetworkImage
              ? ImageOrSvg(
                  networkImage,
                  width: width,
                  height: height,
                  fit: BoxFit.fill,
                  isCircleLoading: false,
                  pickImageOnNull: true,
                  assetImageOnNull: fallbackAsset,
                )
              : Image.asset(
                  fallbackAsset,
                  width: width,
                  height: height,
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                ),
        ),
      ),
    );
  }
}

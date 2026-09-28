import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class ProviderServiceCard extends StatelessWidget {
  const ProviderServiceCard({
    super.key,
    required this.service,
    required this.languageCode,
    required this.onTap,
  });

  final ProviderServiceEntity service;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = service.provider?.coverImageUrl;
    final costText = service.cost % 1 == 0
        ? service.cost.toStringAsFixed(0)
        : service.cost.toStringAsFixed(2);

    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.lightBorder),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageOrSvg(
                  cover,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  pickImageOnNull: true,
                  assetImageOnNull: AppAssets.homeCategoryServices,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name.localized(languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(4),
                    Text(
                      service.serviceType.name.localized(languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.textGrey,
                      ),
                    ),
                    if (service.description.trim().isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.textBodySecondary,
                        ),
                      ),
                    ],
                    const Gap(8),
                    Text(
                      '$costText ${'EGP'.tr}',
                      style: AppFont.font14W700Black.copyWith(
                        color: AppColor.guestOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

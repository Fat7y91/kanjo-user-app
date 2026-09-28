import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_assets.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/entities/service_rating_entity.dart';
import 'package:heraj/features/services/presentation/managers/services_actions_mixin.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class ServiceProviderDetailsScreen extends ConsumerStatefulWidget {
  const ServiceProviderDetailsScreen({
    super.key,
    required this.serviceProviderId,
    this.initialService,
  });

  final int serviceProviderId;
  final ProviderServiceEntity? initialService;

  @override
  ConsumerState<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends ConsumerState<ServiceProviderDetailsScreen>
    with ServiceProviderDetailsActionsMixin {
  @override
  Widget build(BuildContext context) {
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final asyncProvider =
        ref.watch(fetchServiceProviderProvider(widget.serviceProviderId));
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: asyncProvider.customWhen(
        ref: ref,
        refreshable:
            fetchServiceProviderProvider(widget.serviceProviderId).future,
        loading: () => const PageLoadingWidget(),
        error: (err, trace) => CustomErrorWidget(
          object: err,
          stackTrace: trace,
          onRetry: () async {
            ref.invalidate(
              fetchServiceProviderProvider(widget.serviceProviderId),
            );
          },
        ),
        data: (provider) {
          final rating = provider.ratingSummary.average;
          final services = provider.services;
          final types = <int, String>{};
          for (final service in services) {
            types[service.serviceType.id] =
                service.serviceType.name.localized(languageCode);
          }
          if (provider.serviceType != null &&
              !types.containsKey(provider.serviceType!.id)) {
            types[provider.serviceType!.id] =
                provider.serviceType!.name.localized(languageCode);
          }
          final zones = <String>{};
          for (final service in services) {
            for (final zone in service.serviceZones) {
              if (zone.name.trim().isNotEmpty) zones.add(zone.name.trim());
            }
          }
          final selectedService = widget.initialService ??
              (services.isNotEmpty ? services.first : null);

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Get.back(closeOverlays: true),
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                  color: AppColor.black,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  provider.companyName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFont.font16W400Black.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 48,
                                child: Center(
                                  child: InkWell(
                                    onTap: ref.watch(
                                          isLoadingProvider(
                                            'startServiceConversation',
                                          ),
                                        )
                                        ? null
                                        : () => messageProvider(
                                              providerId: provider.id,
                                              companyName: provider.companyName,
                                            ),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ref.watch(
                                            isLoadingProvider(
                                              'startServiceConversation',
                                            ),
                                          )
                                          ? const LoadingWidget(size: 18)
                                          : ImageOrSvg(
                                              AppAssets.serviceChat,
                                              width: 20,
                                              height: 20,
                                              isLocal: true,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _ProfileHeader(provider: provider),
                            const Gap(16),
                            _StatsRow(
                              ordersCount: provider.ordersCount,
                              daysSinceJoin: provider.daysSinceJoin,
                              rating: rating,
                              reviewsCount: provider.ratingSummary.count,
                            ),
                            const Gap(16),
            _ActionButtons(
              isMessaging: ref.watch(
                isLoadingProvider('startServiceConversation'),
              ),
              onCall: () => callProvider(provider.phone),
              onMessage: () => messageProvider(
                providerId: provider.id,
                companyName: provider.companyName,
              ),
            ),
                            const Gap(16),
                            if (provider.description.trim().isNotEmpty)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  provider.description,
                                  style: AppFont.font14W500Black.copyWith(
                                    color: AppColor.textGrey,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            if (zones.isNotEmpty) ...[
                              const Gap(8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: ImageOrSvg(
                                      AppAssets.serviceLocation,
                                      width: 16,
                                      height: 16,
                                      isLocal: true,
                                    ),
                                  ),
                                  const Gap(6),
                                  Expanded(
                                    child: Text(
                                      '${'Zones'.tr}: ${zones.join(' • ')}',
                                      style: AppFont.font12w400Black.copyWith(
                                        color: AppColor.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Gap(16),
                            const Divider(height: 1, color: AppColor.lightBorder),
                            if (types.isNotEmpty) ...[
                              const Gap(16),
                              SizedBox(
                                height: 40,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var i = 0;
                                          i < types.values.length;
                                          i++) ...[
                                        if (i > 0) const Gap(8),
                                        _ServiceTypeChip(
                                          label: types.values.elementAt(i),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const Gap(16),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                'Service reviews'.tr,
                                style: AppFont.font18W700Black,
                              ),
                            ),
                            const Gap(8),
                          ],
                        ),
                      ),
                    ),
                    if (provider.ratings.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Text(
                            'No reviews yet'.tr,
                            style: AppFont.font14W500Black.copyWith(
                              color: AppColor.textGrey,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 170,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < provider.ratings.length;
                                    i++) ...[
                                  if (i > 0) const Gap(10),
                                  _ReviewCard(rating: provider.ratings[i]),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SliverGap(24),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomFilledButton(
                    text: 'Book now'.tr,
                    height: 48,
                    width: MediaQuery.sizeOf(context).width - 32,
                    gradient: AppColor.defaultPrimaryGradient2,
                    radius: 30,
                    onPressed: () => openBookService(
                      provider: provider,
                      service: selectedService,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.provider});

  final ServiceProviderEntity provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: ImageOrSvg(
                  provider.profileImageUrl ?? provider.coverImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  pickImageOnNull: true,
                  assetImageOnNull: AppAssets.homeCategoryServices,
                ),
              ),
              Positioned(
                left: 2,
                bottom: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Text(
          provider.companyName,
          textAlign: TextAlign.center,
          style: AppFont.font16W600Black.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Certified and trusted company'.tr,
              style: AppFont.font14W600Black.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            SizedBox(
              width: 24,
              height: 24,
              child: ImageOrSvg(
                AppAssets.verify,
                width: 24,
                height: 24,
                isLocal: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.ordersCount,
    required this.daysSinceJoin,
    required this.rating,
    required this.reviewsCount,
  });

  final int ordersCount;
  final int daysSinceJoin;
  final double? rating;
  final int reviewsCount;

  @override
  Widget build(BuildContext context) {
    final ratingText =
        rating == null ? '-' : rating!.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '$ordersCount',
              label: 'Service orders'.tr,
            ),
          ),
          Container(width: 1, height: 35, color: AppColor.lightBorder),
          Expanded(
            child: _StatCell(
              value: '$daysSinceJoin ${'Days'.tr}',
              label: 'Joined since'.tr,
            ),
          ),
          Container(width: 1, height: 35, color: AppColor.lightBorder),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ratingText, style: AppFont.font14W500Black),
                    const Gap(4),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: ImageOrSvg(
                        AppAssets.starFilled,
                        width: 16,
                        height: 16,
                        isLocal: true,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '($reviewsCount)',
                      style: AppFont.font14W500Black.copyWith(
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'Rating'.tr,
                  style: AppFont.font12w400Black.copyWith(
                    color: AppColor.textGrey,
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

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppFont.font16W600Black),
        const Gap(4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppFont.font12w400Black.copyWith(color: AppColor.textGrey),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onCall,
    required this.onMessage,
    required this.isMessaging,
  });

  final VoidCallback onCall;
  final VoidCallback onMessage;
  final bool isMessaging;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomFilledButton(
                text: 'Call'.tr,
                height: 40,
                width: constraints.maxWidth,
                radius: 30,
                gradient: AppColor.defaultPrimaryGradient2,
                widget: SizedBox(
                  width: 16,
                  height: 16,
                  child: SvgPicture.asset(
                    AppAssets.servicePhone,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onPressed: onCall,
              );
            },
          ),
        ),
        const Gap(8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomOutlinedButton(
                text: 'Message'.tr,
                height: 40,
                width: constraints.maxWidth,
                radius: 30,
                widget: SizedBox(
                  width: 16,
                  height: 16,
                  child: isMessaging
                      ? const LoadingWidget(size: 16)
                      : ImageOrSvg(
                          AppAssets.serviceChat,
                          width: 16,
                          height: 16,
                          isLocal: true,
                        ),
                ),
                onPressed: isMessaging ? null : onMessage,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Text(
        label,
        style: AppFont.font14W600Black.copyWith(color: AppColor.primary),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.rating});

  final ServiceRatingEntity rating;

  @override
  Widget build(BuildContext context) {
    final stars = rating.rating.round().clamp(0, 5);
    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: ImageOrSvg(
                  rating.userImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  pickImageOnNull: true,
                  assetImageOnNull: AppAssets.profile,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.userName.isEmpty
                          ? 'User'.tr
                          : rating.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.font14W500Black,
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++) ...[
                          if (i > 1) const Gap(4),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: ImageOrSvg(
                              i <= stars
                                  ? AppAssets.starFilled
                                  : AppAssets.starEmpty,
                              width: 16,
                              height: 16,
                              isLocal: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            rating.comment.isEmpty ? 'No comment'.tr : rating.comment,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppFont.font12w400Black.copyWith(
              color: const Color(0xFF949494),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/offers/presentation/managers/offers_actions_mixin.dart';
import 'package:heraj/features/offers/presentation/managers/offers_provider.dart';
import 'package:heraj/features/offers/presentation/view/widgets/offer_item_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

import '../../../../config/app_assets.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen>
    with OffersActionsMixin {
  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(fetchOffersProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: AppColor.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Offers'.tr,
                      style: AppFont.font18W700Black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 24, height: 24),
                ],
              ),
            ),
            Expanded(
              child: offersAsync.customWhen(
                ref: ref,
                refreshable: fetchOffersProvider.future,
                skipLoadingOnRefresh: true,
                loading: () => const PageLoadingWidget(),
                data: (offers) {
                  if (offers.isEmpty) {
                    return Center(
                      child: Text(
                        'No offers yet'.tr,
                        style: AppFont.font14W500Black,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(fetchOffersProvider);
                      try {
                        await ref.read(fetchOffersProvider.future);
                      } catch (_) {}
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            16,
                            0,
                            MediaQuery.paddingOf(context).bottom + 24,
                          ),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childCount: offers.length,
                            itemBuilder: (context, index) {
                              final offer = offers[index];
                              return OfferItemCard(
                                offer: offer,
                                languageCode: languageCode,
                                height: 132,
                                backgroundAsset: AppAssets.offerBacks.first,
                                onTap: () => onOfferTap(offer),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

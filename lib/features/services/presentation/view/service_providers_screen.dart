import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/presentation/managers/service_providers_list_provider.dart';
import 'package:heraj/features/services/presentation/managers/service_providers_screen_actions_mixin.dart';
import 'package:heraj/features/services/presentation/managers/services_provider.dart';
import 'package:heraj/features/services/presentation/view/widgets/service_providers_type_selector.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_card.dart';
import 'package:heraj/features/store/presentation/view/widgets/store_search_bar.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/ui/shared_widgets/sliver_delegate.dart';

class ServiceProvidersScreen extends ConsumerStatefulWidget {
  const ServiceProvidersScreen({
    super.key,
    this.serviceTypeId,
    this.title,
  });

  final int? serviceTypeId;
  final String? title;

  @override
  ConsumerState<ServiceProvidersScreen> createState() =>
      _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends ConsumerState<ServiceProvidersScreen>
    with ServiceProvidersScreenActionsMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final typeId = widget.serviceTypeId;
      if (typeId != null && typeId > 0) {
        ref.read(serviceProvidersSelectedTypeIdProvider.notifier).state =
            typeId;
      }
    });
  }

  @override
  void dispose() {
    cancelSearchDebounce();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(serviceProvidersQueryProvider);
    final providersAsync = ref.watch(fetchServiceProvidersProvider(params));
    final vendors = ref.watch(filteredServiceProviderVendorsProvider);
    final languageCode = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchServiceTypesProvider);
            ref.invalidate(fetchServiceProvidersProvider(params));
            await Future.wait([
              ref.read(fetchServiceTypesProvider.future),
              ref.read(fetchServiceProvidersProvider(params).future),
            ].map((future) => future.then<void>((_) {}, onError: (_) {})));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: AppColor.textDark,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.title ?? 'Service providers'.tr,
                          style: AppFont.font18W700Black.copyWith(
                            color: AppColor.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24, height: 24),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: SliverDelegate(
                  height: 72,
                  child: StoreSearchBar(onChanged: onSearchChanged),
                ),
              ),
              const SliverToBoxAdapter(child: ServiceProvidersTypeSelector()),
              const SliverGap(8),
              providersAsync.customWhen(
                ref: ref,
                refreshable: fetchServiceProvidersProvider(params).future,
                loading: () => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const Gap(10);
                        return const ShimmerEffect(
                          enable: true,
                          child: StoreCardPlaceholder(),
                        );
                      },
                      childCount: 5,
                    ),
                  ),
                ),
                error: (err, trace) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: CustomErrorWidget(
                    object: err,
                    stackTrace: trace,
                    onRetry: () async {
                      ref.invalidate(
                        fetchServiceProvidersProvider(params),
                      );
                    },
                  ),
                ),
                data: (_) {
                  if (vendors.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No services found'.tr,
                          style: AppFont.font16W500Black,
                        ),
                      ),
                    );
                  }
                  final rowCount = vendors.length * 2 - 1;
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) return const Gap(10);
                          final vendor = vendors[index ~/ 2];
                          return StoreCard(
                            vendor: vendor,
                            languageCode: languageCode,
                            onTap: () => openProviderDetails(vendor),
                          );
                        },
                        childCount: rowCount,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

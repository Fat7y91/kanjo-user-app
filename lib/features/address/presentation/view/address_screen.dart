import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/address/presentation/view/widgets/address_widget.dart';
import 'package:heraj/features/address/presentation/view/widgets/animated_background.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import '../../../../ui/shared_widgets/not_found_widget.dart';
import '../managers/address_provider.dart';
import 'address_details_screen.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressesProvider = ref.watch(fetchAddressesProvider);
    return Scaffold(
      body: Stack(
        children: [
          AddressAnimatedBackground(
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
                    "My Addresses".tr,
                    style: AppFont.font18W700Black,
                  ),
                  centerTitle: true,
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchAddressesProvider);
                  },
                  child: addressesProvider.customWhen(
                    ref: ref,
                    refreshable: fetchAddressesProvider.future,
                    data: (addresses) {
                      if (addresses.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: NotFoundWidget(
                              title: "No Addresses Found".tr,
                              haveIcon: true,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          const Gap(16),
                          ...addresses.asMap().entries.map((entry) {
                            return AddressCard(
                              address: entry.value,
                              index: entry.key,
                            );
                          }),
                          Gap(MediaQuery.of(context).padding.bottom + 100),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Floating Add Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
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
              child: CustomFilledButton(
                text: "Add Address".tr,
                onPressed: () async {
                  final result =
                      await Get.to(() => const AddressDetailsScreen());
                  if (result == true) {
                    ref.invalidate(fetchAddressesProvider);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/home/presentation/managers/home_logic_mixin.dart';
import 'package:heraj/features/home/presentation/view/widgets/home_floating_button.dart';
import 'components/home_active_order_component.dart';
import 'components/home_categories_component.dart';
import 'components/home_discover_places_component.dart';
import 'components/home_header_component.dart';
import 'components/home_k_service_banner_component.dart';
import 'components/home_package_shipment_component.dart';
import 'components/home_products_component.dart';
import 'components/home_promo_banner_component.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with HomeLogicMixin {
  @override
  void initState() {
    super.initState();
    showFloatingCart = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    showFloatingCart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = dataManager.isGuest;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isGuest
          ? null
          : ValueListenableBuilder<bool>(
              valueListenable: showFloatingCart,
              builder: (context, show, _) => AnimatedFB(show: show),
            ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) =>
              onScrollNotification(notification, showFloatingCart),
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: HomeHeaderComponent()),
              SliverToBoxAdapter(child: HomeActiveOrderComponent()),
              SliverToBoxAdapter(child: HomeCategoriesComponent()),
              SliverToBoxAdapter(child: HomeKServiceBannerComponent()),
              SliverToBoxAdapter(child: HomePackageShipmentComponent()),
              SliverToBoxAdapter(child: HomeDiscoverPlacesComponent()),
              SliverToBoxAdapter(child: HomePromoBannerComponent()),
              // HomeProductsComponent(),
              SliverGap(130),
            ],
          ),
        ),
      ),
    );
  }
}

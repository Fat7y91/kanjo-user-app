import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/ui/shared_widgets/not_authorized_widget.dart';
import '../../../../config/app_font.dart';
import 'widgets/my_orders_tab.dart';
import 'widgets/orders_tab_switcher.dart';
import 'widgets/package_shipments_tab.dart';
import 'widgets/service_bookings_tab.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final ValueNotifier<int> _tabIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final tab = args is Map ? args['tab'] : null;
    final initialTab = tab is int
        ? tab
        : int.tryParse(tab?.toString() ?? '') ?? 0;
    _tabIndex = ValueNotifier(initialTab.clamp(0, 3));
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((dataManager.getToken() ?? '').isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.pageBackgroundGrey,
        body: const SafeArea(
          child: Center(child: NotAuthorizedWidget()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _OrdersHeader(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: ValueListenableBuilder<int>(
                valueListenable: _tabIndex,
                builder: (context, tab, _) {
                  return OrdersTabSwitcher(
                    selectedIndex: tab,
                    onChanged: (index) => _tabIndex.value = index,
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _tabIndex,
                builder: (context, tab, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (tab) {
                      1 => const MyOrdersTab(
                          key: ValueKey('scheduled'),
                          scheduledOnly: true,
                        ),
                      2 => const ServiceBookingsTab(key: ValueKey('bookings')),
                      3 => const PackageShipmentsTab(
                          key: ValueKey('package_shipments'),
                        ),
                      _ => const MyOrdersTab(
                          key: ValueKey('orders'),
                          scheduledOnly: false,
                        ),
                    },
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

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'My Orders'.tr,
      style: AppFont.font18W700Black,
    );
  }
}

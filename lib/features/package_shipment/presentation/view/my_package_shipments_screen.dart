import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/package_shipment/presentation/view/create_package_shipment_screen.dart';
import 'package:heraj/features/package_shipment/presentation/view/widgets/package_shipments_list_body.dart';

class MyPackageShipmentsScreen extends StatelessWidget {
  const MyPackageShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('My package shipments'.tr, style: AppFont.font16W700Black),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const CreatePackageShipmentScreen()),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const PackageShipmentsListBody(),
    );
  }
}

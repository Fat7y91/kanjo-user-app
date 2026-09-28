import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/features/vendor/data/models/vendor_type_model.dart';
import 'package:heraj/features/vendor/domain/entities/vendor_type_name_entity.dart';

VendorModel vendorFromServiceProvider(
  ServiceProviderEntity provider, {
  VendorTypeModel? servicesType,
}) {
  final typeName = servicesType?.name ??
      VendorTypeNameEntity(
        ar: provider.serviceType?.name.ar.isNotEmpty == true
            ? provider.serviceType!.name.ar
            : 'خدمات',
        en: provider.serviceType?.name.en.isNotEmpty == true
            ? provider.serviceType!.name.en
            : 'Services',
      );
  return VendorModel(
    id: provider.id,
    name: provider.companyName,
    slug: '',
    logoUrl: provider.profileImageUrl,
    coverImageUrl: provider.coverImageUrl,
    listingPosition: 0,
    availabilityStatus: '',
    isAcceptingOrders: true,
    pricesIncludeVat: false,
    busyLateOrderDelayMinutes: 0,
    ratingSummary: provider.ratingSummary,
    type: VendorTypeModel(
      id: servicesType?.id ?? provider.serviceType?.id ?? 0,
      key: servicesType?.key.isNotEmpty == true
          ? servicesType!.key
          : 'services',
      name: typeName,
      image: servicesType?.image,
      imageUrl: servicesType?.imageUrl,
      returnsToVendor: servicesType?.returnsToVendor ?? false,
      tracksInventory: servicesType?.tracksInventory ?? false,
      allowsProductAdditions: servicesType?.allowsProductAdditions ?? false,
      isActive: servicesType?.isActive ?? true,
      sortOrder: servicesType?.sortOrder ?? 0,
    ),
    isServiceProvider: true,
  );
}

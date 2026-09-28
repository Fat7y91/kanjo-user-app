import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/main.dart';

import '../../domain/entities/package_dropoff_input.dart';
import '../../domain/entities/package_price_quote_entity.dart';
import '../../domain/entities/package_shipment_entity.dart';
import '../../domain/entities/package_size_entity.dart';
import '../../domain/use_case/package_shipment_use_cases.dart';

enum PackageShipmentPaymentMethod {
  cash,
  online;

  String get apiValue => switch (this) {
        PackageShipmentPaymentMethod.cash => 'cod',
        PackageShipmentPaymentMethod.online => 'online',
      };
}

class PackageShipmentDraft {
  const PackageShipmentDraft({
    this.step = 0,
    this.selectedSize,
    this.pickupAddress,
    this.dropoffs = const [],
    this.packageImage,
    this.paymentMethod = PackageShipmentPaymentMethod.cash,
    this.priceQuote,
  });

  final int step;
  final PackageSizeEntity? selectedSize;
  final AddressModel? pickupAddress;
  final List<PackageDropoffInput> dropoffs;
  final File? packageImage;
  final PackageShipmentPaymentMethod paymentMethod;
  final PackagePriceQuoteEntity? priceQuote;

  PackageShipmentDraft copyWith({
    int? step,
    PackageSizeEntity? selectedSize,
    AddressModel? pickupAddress,
    List<PackageDropoffInput>? dropoffs,
    File? packageImage,
    bool clearPackageImage = false,
    PackageShipmentPaymentMethod? paymentMethod,
    PackagePriceQuoteEntity? priceQuote,
    bool clearPriceQuote = false,
  }) {
    return PackageShipmentDraft(
      step: step ?? this.step,
      selectedSize: selectedSize ?? this.selectedSize,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffs: dropoffs ?? this.dropoffs,
      packageImage:
          clearPackageImage ? null : (packageImage ?? this.packageImage),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      priceQuote: clearPriceQuote ? null : (priceQuote ?? this.priceQuote),
    );
  }
}

class PackageShipmentDraftNotifier extends StateNotifier<PackageShipmentDraft> {
  PackageShipmentDraftNotifier() : super(const PackageShipmentDraft());

  void setStep(int step) => state = state.copyWith(step: step);

  void selectSize(PackageSizeEntity size) {
    state = state.copyWith(
      selectedSize: size,
      clearPriceQuote: true,
    );
  }

  void setPickup(AddressModel address) {
    state = state.copyWith(
      pickupAddress: address,
      clearPriceQuote: true,
    );
  }

  void setDropoffs(List<PackageDropoffInput> dropoffs) {
    state = state.copyWith(
      dropoffs: dropoffs,
      clearPriceQuote: true,
    );
  }

  void addDropoff(PackageDropoffInput dropoff) {
    state = state.copyWith(
      dropoffs: [...state.dropoffs, dropoff],
      clearPriceQuote: true,
    );
  }

  void updateDropoff(int index, PackageDropoffInput dropoff) {
    if (index < 0 || index >= state.dropoffs.length) return;
    final next = [...state.dropoffs];
    next[index] = dropoff;
    state = state.copyWith(dropoffs: next, clearPriceQuote: true);
  }

  void removeDropoff(int index) {
    if (index < 0 || index >= state.dropoffs.length) return;
    final next = [...state.dropoffs]..removeAt(index);
    state = state.copyWith(dropoffs: next, clearPriceQuote: true);
  }

  void setPackageImage(File? file) {
    state = state.copyWith(
      packageImage: file,
      clearPackageImage: file == null,
    );
  }

  void setPaymentMethod(PackageShipmentPaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setPriceQuote(PackagePriceQuoteEntity? quote) {
    state = state.copyWith(
      priceQuote: quote,
      clearPriceQuote: quote == null,
    );
  }

  void reset() => state = const PackageShipmentDraft();
}

final packageShipmentDraftProvider = StateNotifierProvider.autoDispose<
    PackageShipmentDraftNotifier, PackageShipmentDraft>(
  (ref) => PackageShipmentDraftNotifier(),
);

final fetchPackageSizesProvider =
    FutureProvider.autoDispose<List<PackageSizeEntity>>((ref) async {
  final res = await getIt<FetchPackageSizesUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

final fetchMyPackageShipmentsProvider =
    FutureProvider.autoDispose<List<PackageShipmentEntity>>((ref) async {
  final res = await getIt<FetchMyPackageShipmentsUseCase>().call(
    (page: 1, perPage: 50),
  );
  return res.fold((l) => throw l, (r) => r.data);
});

final fetchPackageShipmentDetailsProvider = FutureProvider.autoDispose
    .family<PackageShipmentEntity, String>((ref, shipmentId) async {
  final res =
      await getIt<FetchPackageShipmentDetailsUseCase>().call(shipmentId);
  return res.fold((l) => throw l, (r) => r);
});

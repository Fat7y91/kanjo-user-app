import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tuple/tuple.dart';

import '../../../../../core/service/loading_provider.dart';
import '../../../../../main.dart';
import '../../../../../ui/ui.dart';
import '../../data/model/address_model.dart';
import '../../domain/use_case/address_use_cases.dart';
import 'address_provider.dart';
import '../view/map_selector_screen.dart';

mixin AddressDetailsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  FormGroup get form;
  AddressModel? get editingAddress;
  bool get isEditing;

  Future<void> _onActionSuccess(String message) async {
    ref.invalidate(fetchAddressesProvider);
    await UIHelper.showAlert(message, type: DialogType.success);
    if (!mounted) return;
    Get.back(result: true);
  }

  Future<void> openLocationSelector() async {
    final lat = form.control('latitude').value as double?;
    final lng = form.control('longitude').value as double?;
    final initial = (lat != null && lng != null) ? [lng, lat] : null;

    final result = await Get.to<List<double>>(
      () => MapSelectorScreen(initialCoordinates: initial),
    );
    if (result == null || result.length < 2) return;

    form.control('longitude').value = result[0];
    form.control('latitude').value = result[1];
  }

  Future<bool> _setDefaultIfNeeded(String addressId, bool wantDefault) async {
    if (!wantDefault || addressId.isEmpty) return true;
    final res = await getIt<SetDefaultAddressUseCase>().call(addressId);
    return res.fold(
      (l) {
        UIHelper.showAlert(l.message, type: DialogType.error);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> saveAddress() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return false;
    }

    try {
      ref.read(isLoadingProvider('saveAddress').notifier).state = true;

      final wantDefault = form.control('is_default').value as bool? ?? false;
      final body = <String, dynamic>{
        'label': form.control('label').value,
        'address': form.control('address').value,
        'latitude': form.control('latitude').value,
        'longitude': form.control('longitude').value,
        'is_default': wantDefault,
      };

      if (isEditing) {
        final res = await getIt<UpdateAddressUseCase>().call(
          Tuple2(editingAddress!.id, body),
        );
        final ok = await res.fold(
          (l) async {
            UIHelper.showAlert(l.message, type: DialogType.error);
            return false;
          },
          (_) => _setDefaultIfNeeded(editingAddress!.id, wantDefault),
        );
        if (!ok) return false;
        await _onActionSuccess('Address updated successfully'.tr);
        return true;
      }

      final res = await getIt<AddAddressUseCase>().call(body);
      final ok = await res.fold(
        (l) async {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (created) => _setDefaultIfNeeded(created.id, wantDefault),
      );
      if (!ok) return false;
      await _onActionSuccess('Address added successfully'.tr);
      return true;
    } finally {
      ref.read(isLoadingProvider('saveAddress').notifier).state = false;
    }
  }

  Future<bool> deleteAddress() async {
    if (!isEditing || editingAddress == null) return false;
    try {
      ref.read(isLoadingProvider('deleteAddress').notifier).state = true;
      final res =
          await getIt<DeleteAddressUseCase>().call(editingAddress!.id);
      final success = res.fold(
        (l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
          return false;
        },
        (_) => true,
      );
      if (!success) return false;
      await _onActionSuccess('Address deleted successfully'.tr);
      return true;
    } finally {
      ref.read(isLoadingProvider('deleteAddress').notifier).state = false;
    }
  }

  LatLng get mapPosition {
    final lat = form.control('latitude').value as double?;
    final lng = form.control('longitude').value as double?;
    if (lat != null && lng != null) return LatLng(lat, lng);
    return const LatLng(30.0444, 31.2357);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/local_data_manager.dart';

final hideNavBarProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final rootViewProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

final isVendorFlowProvider = StateProvider.autoDispose<bool>((ref) {
  final user = ref.watch(userProvider);
  final hasVendorRole = (user?.role ?? "user") == "vendor";

  if (hasVendorRole) {
    if (dataManager.hasVendorFlowPreference()) {
      return dataManager.getVendorFlow();
    } else {
      return true;
    }
  }

  return false;
});
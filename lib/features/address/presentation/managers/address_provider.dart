import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/model/address_model.dart';
import '../../domain/use_case/address_use_cases.dart';

enum AddressType{
  home,
  work,
  apartment,
}

final fetchAddressesProvider = FutureProvider.autoDispose<List<AddressModel>>((ref) async {
  final res = await getIt<FetchAddressesUseCase>().call();
  return res.fold(
    (l) => throw l,
    (r) => r,
  );
});

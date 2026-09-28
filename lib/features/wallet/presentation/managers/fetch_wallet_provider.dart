import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/wallet/data/models/wallet_model.dart';
import 'package:heraj/features/wallet/domain/use_case/fetch_wallet_use_case.dart';
import 'package:heraj/main.dart';

final fetchWalletProvider =
    FutureProvider.autoDispose<WalletModel>((ref) async {
  final res = await getIt<FetchWalletUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

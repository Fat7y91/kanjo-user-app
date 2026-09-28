import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/wallet_model.dart';
import '../repo/wallet_repo.dart';

class FetchWalletUseCase extends UseCaseNoParam<WalletModel> {
  final WalletRepo walletRepo;

  FetchWalletUseCase({required this.walletRepo});

  @override
  Future<Either<Failure, WalletModel>> call() {
    return walletRepo.getWallet();
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/wallet_model.dart';

abstract class WalletRepo {
  Future<Either<Failure, WalletModel>> getWallet();
}

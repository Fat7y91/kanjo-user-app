import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repo/wallet_repo.dart';
import '../data_source/wallet_data_source.dart';
import '../models/wallet_model.dart';

class WalletRepoImp implements WalletRepo {
  final WalletDataSource dataSource;

  WalletRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, WalletModel>> getWallet() async {
    try {
      return Right(await dataSource.getWallet());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}

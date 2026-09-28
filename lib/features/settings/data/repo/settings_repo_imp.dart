import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/settings_repo.dart';
import '../data_source/settings_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepoImpl extends SettingsRepo {
  final SettingsDataSource dataSource;

  SettingsRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, SettingsModel>> getSettings() async {
    try {
      final settings = await dataSource.getSettings();
      return Right(settings);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
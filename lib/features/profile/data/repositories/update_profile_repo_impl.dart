import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../domain/repositories/update_profile_repo.dart';
import '../data_sources/update_profile_date_source.dart';

class UpdateProfileRepoImpl extends UpdateProfileRepo {
  final UpdateProfileDataSource updateProfileDataSource;

  UpdateProfileRepoImpl(this.updateProfileDataSource);

  @override
  Future<Either<Failure, String>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await updateProfileDataSource.updateProfile(data);
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}

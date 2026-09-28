import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../../domain/entities/home_sections_content_entity.dart';
import '../../domain/repositories/home_repo.dart';
import '../data_source/home_data_source.dart';

class HomeSectionsRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  const HomeSectionsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, HomeSectionsContentEntity>> getHomeSectionsContent() async {
    try {
      final res = await dataSource.getHomeSectionsContent();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}

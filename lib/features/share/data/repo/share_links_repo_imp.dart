import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/create_share_link_params.dart';
import '../../domain/entities/share_link_entity.dart';
import '../../domain/entities/share_link_resolve_entity.dart';
import '../../domain/repo/share_links_repo.dart';
import '../data_source/share_links_data_source.dart';

class ShareLinksRepoImp extends ShareLinksRepo {
  ShareLinksRepoImp({required this.dataSource});

  final ShareLinksDataSource dataSource;

  @override
  Future<Either<Failure, ShareLinkEntity>> createShareLink(
    CreateShareLinkParams params,
  ) {
    return _guard(() => dataSource.createShareLink(params));
  }

  @override
  Future<Either<Failure, ShareLinkResolveEntity>> resolveShareLink(
    String reference,
  ) {
    return _guard(() => dataSource.resolveShareLink(reference));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
